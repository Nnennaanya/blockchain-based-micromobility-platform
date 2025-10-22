;; Vehicle Registry Smart Contract
;; Manages registration and lifecycle of micromobility vehicles

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-found (err u101))
(define-constant err-already-exists (err u102))
(define-constant err-invalid-status (err u103))
(define-constant err-unauthorized (err u104))
(define-constant err-invalid-vehicle (err u105))

;; Vehicle status constants
(define-constant status-available u1)
(define-constant status-in-use u2)
(define-constant status-maintenance u3)
(define-constant status-decommissioned u4)

;; Data Variables
(define-data-var vehicle-id-nonce uint u0)
(define-data-var total-vehicles uint u0)
(define-data-var platform-fee uint u5) ;; 5% platform fee

;; Data Maps
(define-map vehicles
  { vehicle-id: uint }
  {
    owner: principal,
    vehicle-type: (string-ascii 20),
    model: (string-ascii 50),
    registration-number: (string-ascii 20),
    status: uint,
    location: (string-ascii 100),
    rate-per-minute: uint,
    total-rentals: uint,
    registration-block: uint,
    last-maintenance-block: uint
  }
)

(define-map vehicle-operators
  { operator: principal }
  {
    total-vehicles: uint,
    active-since: uint,
    reputation-score: uint,
    is-verified: bool
  }
)

(define-map vehicle-maintenance-log
  { vehicle-id: uint, log-id: uint }
  {
    reported-by: principal,
    issue-description: (string-ascii 200),
    reported-at: uint,
    resolved: bool
  }
)

(define-map operator-vehicles
  { operator: principal, vehicle-id: uint }
  { registered: bool }
)

;; Private Functions
(define-private (is-valid-status (status uint))
  (or 
    (is-eq status status-available)
    (or 
      (is-eq status status-in-use)
      (or 
        (is-eq status status-maintenance)
        (is-eq status status-decommissioned)
      )
    )
  )
)

;; Read-only Functions
(define-read-only (get-vehicle (vehicle-id uint))
  (map-get? vehicles { vehicle-id: vehicle-id })
)

(define-read-only (get-vehicle-owner (vehicle-id uint))
  (match (map-get? vehicles { vehicle-id: vehicle-id })
    vehicle (ok (get owner vehicle))
    err-not-found
  )
)

(define-read-only (get-vehicle-status (vehicle-id uint))
  (match (map-get? vehicles { vehicle-id: vehicle-id })
    vehicle (ok (get status vehicle))
    err-not-found
  )
)

(define-read-only (get-operator-info (operator principal))
  (map-get? vehicle-operators { operator: operator })
)

(define-read-only (get-total-vehicles)
  (ok (var-get total-vehicles))
)

(define-read-only (get-platform-fee)
  (ok (var-get platform-fee))
)

(define-read-only (is-vehicle-available (vehicle-id uint))
  (match (map-get? vehicles { vehicle-id: vehicle-id })
    vehicle (ok (is-eq (get status vehicle) status-available))
    err-not-found
  )
)

(define-read-only (get-vehicle-rate (vehicle-id uint))
  (match (map-get? vehicles { vehicle-id: vehicle-id })
    vehicle (ok (get rate-per-minute vehicle))
    err-not-found
  )
)

;; Public Functions
(define-public (register-vehicle 
  (vehicle-type (string-ascii 20))
  (model (string-ascii 50))
  (registration-number (string-ascii 20))
  (location (string-ascii 100))
  (rate-per-minute uint)
)
  (let
    (
      (new-vehicle-id (+ (var-get vehicle-id-nonce) u1))
      (caller tx-sender)
    )
    ;; Create vehicle entry
    (map-set vehicles
      { vehicle-id: new-vehicle-id }
      {
        owner: caller,
        vehicle-type: vehicle-type,
        model: model,
        registration-number: registration-number,
        status: status-available,
        location: location,
        rate-per-minute: rate-per-minute,
        total-rentals: u0,
        registration-block: stacks-block-height,
        last-maintenance-block: stacks-block-height
      }
    )
    
    ;; Update operator-vehicles mapping
    (map-set operator-vehicles
      { operator: caller, vehicle-id: new-vehicle-id }
      { registered: true }
    )
    
    ;; Update or create operator info
    (match (map-get? vehicle-operators { operator: caller })
      operator-data
        (map-set vehicle-operators
          { operator: caller }
          (merge operator-data { total-vehicles: (+ (get total-vehicles operator-data) u1) })
        )
      (map-set vehicle-operators
        { operator: caller }
        {
          total-vehicles: u1,
          active-since: stacks-block-height,
          reputation-score: u100,
          is-verified: false
        }
      )
    )
    
    ;; Update nonce and counter
    (var-set vehicle-id-nonce new-vehicle-id)
    (var-set total-vehicles (+ (var-get total-vehicles) u1))
    
    (ok new-vehicle-id)
  )
)

(define-public (update-vehicle-status (vehicle-id uint) (new-status uint))
  (let
    (
      (vehicle-data (unwrap! (map-get? vehicles { vehicle-id: vehicle-id }) err-not-found))
      (caller tx-sender)
    )
    ;; Check if caller is the owner
    (asserts! (is-eq caller (get owner vehicle-data)) err-unauthorized)
    ;; Validate status
    (asserts! (is-valid-status new-status) err-invalid-status)
    
    ;; Update vehicle status
    (map-set vehicles
      { vehicle-id: vehicle-id }
      (merge vehicle-data { status: new-status })
    )
    
    (ok true)
  )
)

(define-public (update-vehicle-location (vehicle-id uint) (new-location (string-ascii 100)))
  (let
    (
      (vehicle-data (unwrap! (map-get? vehicles { vehicle-id: vehicle-id }) err-not-found))
      (caller tx-sender)
    )
    ;; Check if caller is the owner
    (asserts! (is-eq caller (get owner vehicle-data)) err-unauthorized)
    
    ;; Update location
    (map-set vehicles
      { vehicle-id: vehicle-id }
      (merge vehicle-data { location: new-location })
    )
    
    (ok true)
  )
)

(define-public (update-vehicle-rate (vehicle-id uint) (new-rate uint))
  (let
    (
      (vehicle-data (unwrap! (map-get? vehicles { vehicle-id: vehicle-id }) err-not-found))
      (caller tx-sender)
    )
    ;; Check if caller is the owner
    (asserts! (is-eq caller (get owner vehicle-data)) err-unauthorized)
    
    ;; Update rate
    (map-set vehicles
      { vehicle-id: vehicle-id }
      (merge vehicle-data { rate-per-minute: new-rate })
    )
    
    (ok true)
  )
)

(define-public (transfer-vehicle-ownership (vehicle-id uint) (new-owner principal))
  (let
    (
      (vehicle-data (unwrap! (map-get? vehicles { vehicle-id: vehicle-id }) err-not-found))
      (caller tx-sender)
      (current-owner (get owner vehicle-data))
    )
    ;; Check if caller is the owner
    (asserts! (is-eq caller current-owner) err-unauthorized)
    
    ;; Update vehicle owner
    (map-set vehicles
      { vehicle-id: vehicle-id }
      (merge vehicle-data { owner: new-owner })
    )
    
    ;; Update old owner stats
    (match (map-get? vehicle-operators { operator: current-owner })
      old-operator-data
        (map-set vehicle-operators
          { operator: current-owner }
          (merge old-operator-data { 
            total-vehicles: (if (> (get total-vehicles old-operator-data) u0)
                              (- (get total-vehicles old-operator-data) u1)
                              u0)
          })
        )
      true
    )
    
    ;; Update new owner stats
    (match (map-get? vehicle-operators { operator: new-owner })
      new-operator-data
        (map-set vehicle-operators
          { operator: new-owner }
          (merge new-operator-data { 
            total-vehicles: (+ (get total-vehicles new-operator-data) u1)
          })
        )
      (map-set vehicle-operators
        { operator: new-owner }
        {
          total-vehicles: u1,
          active-since: stacks-block-height,
          reputation-score: u100,
          is-verified: false
        }
      )
    )
    
    (ok true)
  )
)

(define-public (increment-rental-count (vehicle-id uint))
  (let
    (
      (vehicle-data (unwrap! (map-get? vehicles { vehicle-id: vehicle-id }) err-not-found))
    )
    ;; Update rental count
    (map-set vehicles
      { vehicle-id: vehicle-id }
      (merge vehicle-data { 
        total-rentals: (+ (get total-rentals vehicle-data) u1)
      })
    )
    
    (ok true)
  )
)

(define-public (set-platform-fee (new-fee uint))
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (var-set platform-fee new-fee)
    (ok true)
  )
)

(define-public (verify-operator (operator principal))
  (let
    (
      (operator-data (unwrap! (map-get? vehicle-operators { operator: operator }) err-not-found))
    )
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    
    (map-set vehicle-operators
      { operator: operator }
      (merge operator-data { is-verified: true })
    )
    
    (ok true)
  )
)

;; title: vehicle-registry
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

