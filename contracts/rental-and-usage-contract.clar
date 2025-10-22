;; Rental and Usage Smart Contract
;; Handles rentals, usage tracking, payments, and maintenance requests

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u200))
(define-constant err-not-found (err u201))
(define-constant err-already-rented (err u202))
(define-constant err-not-rented (err u203))
(define-constant err-unauthorized (err u204))
(define-constant err-invalid-payment (err u205))
(define-constant err-insufficient-funds (err u206))
(define-constant err-rental-active (err u207))
(define-constant err-invalid-maintenance (err u208))

;; Rental status constants
(define-constant rental-status-active u1)
(define-constant rental-status-completed u2)
(define-constant rental-status-cancelled u3)

;; Data Variables
(define-data-var rental-id-nonce uint u0)
(define-data-var maintenance-id-nonce uint u0)
(define-data-var total-rentals uint u0)
(define-data-var total-revenue uint u0)
(define-data-var platform-fee-percentage uint u5) ;; 5%

;; Data Maps
(define-map rentals
  { rental-id: uint }
  {
    vehicle-id: uint,
    renter: principal,
    start-time: uint,
    end-time: uint,
    start-location: (string-ascii 100),
    end-location: (string-ascii 100),
    duration-minutes: uint,
    rate-per-minute: uint,
    total-cost: uint,
    platform-fee: uint,
    status: uint,
    payment-completed: bool
  }
)

(define-map active-rentals
  { vehicle-id: uint }
  {
    rental-id: uint,
    renter: principal,
    start-time: uint
  }
)

(define-map user-rental-history
  { user: principal, rental-id: uint }
  { completed: bool }
)

(define-map maintenance-requests
  { request-id: uint }
  {
    vehicle-id: uint,
    reported-by: principal,
    issue-type: (string-ascii 50),
    description: (string-ascii 200),
    reported-at: uint,
    resolved: bool,
    resolved-at: uint,
    priority: uint
  }
)

(define-map user-stats
  { user: principal }
  {
    total-rentals: uint,
    total-spent: uint,
    total-minutes: uint,
    member-since: uint,
    reputation: uint
  }
)

(define-map vehicle-revenue
  { vehicle-id: uint }
  {
    total-revenue: uint,
    total-rentals: uint,
    total-minutes: uint
  }
)

;; Private Functions
(define-private (calculate-platform-fee (amount uint))
  (/ (* amount (var-get platform-fee-percentage)) u100)
)

(define-private (calculate-rental-cost (duration uint) (rate uint))
  (* duration rate)
)

;; Read-only Functions
(define-read-only (get-rental (rental-id uint))
  (map-get? rentals { rental-id: rental-id })
)

(define-read-only (get-active-rental (vehicle-id uint))
  (map-get? active-rentals { vehicle-id: vehicle-id })
)

(define-read-only (is-vehicle-rented (vehicle-id uint))
  (is-some (map-get? active-rentals { vehicle-id: vehicle-id }))
)

(define-read-only (get-user-stats (user principal))
  (map-get? user-stats { user: user })
)

(define-read-only (get-total-rentals)
  (ok (var-get total-rentals))
)

(define-read-only (get-total-revenue)
  (ok (var-get total-revenue))
)

(define-read-only (get-maintenance-request (request-id uint))
  (map-get? maintenance-requests { request-id: request-id })
)

(define-read-only (get-vehicle-revenue (vehicle-id uint))
  (map-get? vehicle-revenue { vehicle-id: vehicle-id })
)

(define-read-only (get-platform-fee-percentage)
  (ok (var-get platform-fee-percentage))
)

;; Public Functions
(define-public (start-rental 
  (vehicle-id uint)
  (rate-per-minute uint)
  (start-location (string-ascii 100))
)
  (let
    (
      (new-rental-id (+ (var-get rental-id-nonce) u1))
      (caller tx-sender)
    )
    ;; Check if vehicle is not already rented
    (asserts! (not (is-vehicle-rented vehicle-id)) err-already-rented)
    
    ;; Create rental entry
    (map-set rentals
      { rental-id: new-rental-id }
      {
        vehicle-id: vehicle-id,
        renter: caller,
        start-time: stacks-block-height,
        end-time: u0,
        start-location: start-location,
        end-location: "",
        duration-minutes: u0,
        rate-per-minute: rate-per-minute,
        total-cost: u0,
        platform-fee: u0,
        status: rental-status-active,
        payment-completed: false
      }
    )
    
    ;; Set active rental
    (map-set active-rentals
      { vehicle-id: vehicle-id }
      {
        rental-id: new-rental-id,
        renter: caller,
        start-time: stacks-block-height
      }
    )
    
    ;; Update user rental history
    (map-set user-rental-history
      { user: caller, rental-id: new-rental-id }
      { completed: false }
    )
    
    ;; Update nonce
    (var-set rental-id-nonce new-rental-id)
    
    (ok new-rental-id)
  )
)

(define-public (end-rental 
  (rental-id uint)
  (end-location (string-ascii 100))
)
  (let
    (
      (rental-data (unwrap! (map-get? rentals { rental-id: rental-id }) err-not-found))
      (caller tx-sender)
      (vehicle-id (get vehicle-id rental-data))
      (start-time (get start-time rental-data))
      (duration (- stacks-block-height start-time))
      (rate (get rate-per-minute rental-data))
      (total-cost (calculate-rental-cost duration rate))
      (platform-fee (calculate-platform-fee total-cost))
      (net-amount (- total-cost platform-fee))
    )
    ;; Verify caller is the renter
    (asserts! (is-eq caller (get renter rental-data)) err-unauthorized)
    ;; Verify rental is active
    (asserts! (is-eq (get status rental-data) rental-status-active) err-not-rented)
    
    ;; Update rental data
    (map-set rentals
      { rental-id: rental-id }
      (merge rental-data {
        end-time: stacks-block-height,
        end-location: end-location,
        duration-minutes: duration,
        total-cost: total-cost,
        platform-fee: platform-fee,
        status: rental-status-completed,
        payment-completed: true
      })
    )
    
    ;; Remove active rental
    (map-delete active-rentals { vehicle-id: vehicle-id })
    
    ;; Update user rental history
    (map-set user-rental-history
      { user: caller, rental-id: rental-id }
      { completed: true }
    )
    
    ;; Update user stats
    (match (map-get? user-stats { user: caller })
      existing-stats
        (map-set user-stats
          { user: caller }
          (merge existing-stats {
            total-rentals: (+ (get total-rentals existing-stats) u1),
            total-spent: (+ (get total-spent existing-stats) total-cost),
            total-minutes: (+ (get total-minutes existing-stats) duration)
          })
        )
      (map-set user-stats
        { user: caller }
        {
          total-rentals: u1,
          total-spent: total-cost,
          total-minutes: duration,
          member-since: stacks-block-height,
          reputation: u100
        }
      )
    )
    
    ;; Update vehicle revenue
    (match (map-get? vehicle-revenue { vehicle-id: vehicle-id })
      existing-revenue
        (map-set vehicle-revenue
          { vehicle-id: vehicle-id }
          (merge existing-revenue {
            total-revenue: (+ (get total-revenue existing-revenue) net-amount),
            total-rentals: (+ (get total-rentals existing-revenue) u1),
            total-minutes: (+ (get total-minutes existing-revenue) duration)
          })
        )
      (map-set vehicle-revenue
        { vehicle-id: vehicle-id }
        {
          total-revenue: net-amount,
          total-rentals: u1,
          total-minutes: duration
        }
      )
    )
    
    ;; Update global stats
    (var-set total-rentals (+ (var-get total-rentals) u1))
    (var-set total-revenue (+ (var-get total-revenue) total-cost))
    
    (ok {
      rental-id: rental-id,
      duration: duration,
      total-cost: total-cost,
      platform-fee: platform-fee
    })
  )
)

(define-public (cancel-rental (rental-id uint))
  (let
    (
      (rental-data (unwrap! (map-get? rentals { rental-id: rental-id }) err-not-found))
      (caller tx-sender)
      (vehicle-id (get vehicle-id rental-data))
    )
    ;; Verify caller is the renter
    (asserts! (is-eq caller (get renter rental-data)) err-unauthorized)
    ;; Verify rental is active
    (asserts! (is-eq (get status rental-data) rental-status-active) err-not-rented)
    
    ;; Update rental status
    (map-set rentals
      { rental-id: rental-id }
      (merge rental-data { status: rental-status-cancelled })
    )
    
    ;; Remove active rental
    (map-delete active-rentals { vehicle-id: vehicle-id })
    
    (ok true)
  )
)

(define-public (submit-maintenance-request
  (vehicle-id uint)
  (issue-type (string-ascii 50))
  (description (string-ascii 200))
  (priority uint)
)
  (let
    (
      (new-request-id (+ (var-get maintenance-id-nonce) u1))
      (caller tx-sender)
    )
    ;; Create maintenance request
    (map-set maintenance-requests
      { request-id: new-request-id }
      {
        vehicle-id: vehicle-id,
        reported-by: caller,
        issue-type: issue-type,
        description: description,
        reported-at: stacks-block-height,
        resolved: false,
        resolved-at: u0,
        priority: priority
      }
    )
    
    ;; Update nonce
    (var-set maintenance-id-nonce new-request-id)
    
    (ok new-request-id)
  )
)

(define-public (resolve-maintenance-request (request-id uint))
  (let
    (
      (request-data (unwrap! (map-get? maintenance-requests { request-id: request-id }) err-not-found))
    )
    ;; Update maintenance request
    (map-set maintenance-requests
      { request-id: request-id }
      (merge request-data {
        resolved: true,
        resolved-at: stacks-block-height
      })
    )
    
    (ok true)
  )
)

(define-public (set-platform-fee-percentage (new-percentage uint))
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (asserts! (<= new-percentage u100) err-invalid-payment)
    (var-set platform-fee-percentage new-percentage)
    (ok true)
  )
)

(define-public (update-user-reputation (user principal) (new-reputation uint))
  (let
    (
      (user-data (unwrap! (map-get? user-stats { user: user }) err-not-found))
    )
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    
    (map-set user-stats
      { user: user }
      (merge user-data { reputation: new-reputation })
    )
    
    (ok true)
  )
)

;; title: rental-and-usage-contract
;; version:
;; summary:
;; description:

;; traits
;;

;; token definitions
;;

;; constants
;;

;; data vars
;;

;; data maps
;;

;; public functions
;;

;; read only functions
;;

;; private functions
;;

