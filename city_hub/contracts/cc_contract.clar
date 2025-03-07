;; SmartCityInfrastructure Contract - Version 2
;; Added component history tracking and inspection framework

(define-trait city-infrastructure-trait
  (
    (register-component (uint uint) (response bool uint))
    (update-component-condition (uint uint) (response bool uint))
    (get-component-history (uint) (response (list 10 {condition: uint, timestamp: uint}) uint))
    (get-component-condition (uint) (response uint uint))
    (add-inspection-agency (principal uint) (response bool uint))
    (add-inspection (uint uint) (response bool uint))
  )
)

;; Define component condition constants
(define-constant CONDITION_NEW u1)
(define-constant CONDITION_OPERATIONAL u2)
(define-constant CONDITION_NEEDS_MAINTENANCE u3)
(define-constant CONDITION_UNDER_REPAIR u4)

;; Define inspection type constants
(define-constant INSPECTION_STRUCTURAL u1)
(define-constant INSPECTION_ELECTRICAL u2)
(define-constant INSPECTION_ENVIRONMENTAL u3)
(define-constant INSPECTION_SAFETY u4)

;; Error constants
(define-constant ERR_UNAUTHORIZED (err u1))
(define-constant ERR_INVALID_COMPONENT (err u2))
(define-constant ERR_CONDITION_UPDATE_FAILED (err u3))
(define-constant ERR_INVALID_CONDITION (err u4))
(define-constant ERR_INVALID_INSPECTION (err u5))
(define-constant ERR_INSPECTION_EXISTS (err u6))

;; Contract owner
(define-data-var city-admin principal tx-sender)

;; Current timestamp counter
(define-data-var timestamp-counter uint u0)

;; Infrastructure component tracking map
(define-map component-details 
  {component-id: uint} 
  {
    department: principal,
    current-condition: uint,
    history: (list 10 {condition: uint, timestamp: uint})
  }
)

;; Inspection tracking map
(define-map component-inspections
  {component-id: uint, inspection-type: uint}
  {
    inspector: principal,
    timestamp: uint,
    passed: bool
  }
)

;; Approved inspection agencies
(define-map inspection-agencies
  {agency: principal, inspection-type: uint}
  {approved: bool}
)

;; Get current timestamp and increment counter
(define-private (get-current-timestamp)
  (begin
    (var-set timestamp-counter (+ (var-get timestamp-counter) u1))
    (var-get timestamp-counter)
  )
)

;; Only city admin can perform certain actions
(define-read-only (is-city-admin (sender principal))
  (is-eq sender (var-get city-admin))
)

;; Validate condition
(define-private (is-valid-condition (condition uint))
  (or 
    (is-eq condition CONDITION_NEW)
    (is-eq condition CONDITION_OPERATIONAL)
    (is-eq condition CONDITION_NEEDS_MAINTENANCE)
    (is-eq condition CONDITION_UNDER_REPAIR)
  )
)

;; Validate inspection type
(define-private (is-valid-inspection-type (inspection-type uint))
  (or
    (is-eq inspection-type INSPECTION_STRUCTURAL)
    (is-eq inspection-type INSPECTION_ELECTRICAL)
    (is-eq inspection-type INSPECTION_ENVIRONMENTAL)
    (is-eq inspection-type INSPECTION_SAFETY)
  )
)

;; Validate component ID
(define-private (is-valid-component-id (component-id uint))
  (and (> component-id u0) (<= component-id u1000000))
)

;; Check if sender is approved inspection agency
(define-private (is-inspection-agency (agency principal) (inspection-type uint))
  (default-to 
    false
    (get approved (map-get? inspection-agencies {agency: agency, inspection-type: inspection-type}))
  )
)

;; Register a new infrastructure component
(define-public (register-component (component-id uint) (initial-condition uint))
  (begin
    (asserts! (is-valid-component-id component-id) ERR_INVALID_COMPONENT)
    (asserts! (is-valid-condition initial-condition) ERR_INVALID_CONDITION)
    (asserts! (or (is-city-admin tx-sender) (is-eq initial-condition CONDITION_NEW)) ERR_UNAUTHORIZED)
    
    (map-set component-details 
      {component-id: component-id}
      {
        department: tx-sender,
        current-condition: initial-condition,
        history: (list {condition: initial-condition, timestamp: (get-current-timestamp)})
      }
    )
    (ok true)
  )
)

;; Update infrastructure component condition
(define-public (update-component-condition (component-id uint) (new-condition uint))
  (let 
    (
      (component (unwrap! (map-get? component-details {component-id: component-id}) ERR_INVALID_COMPONENT))
    )
    (asserts! (is-valid-component-id component-id) ERR_INVALID_COMPONENT)
    (asserts! (is-valid-condition new-condition) ERR_INVALID_CONDITION)
    (asserts! 
      (or 
        (is-city-admin tx-sender)
        (is-eq (get department component) tx-sender)
      ) 
      ERR_UNAUTHORIZED
    )
    
    (map-set component-details 
      {component-id: component-id}
      (merge component 
        {
          current-condition: new-condition,
          history: (unwrap-panic 
            (as-max-len? 
              (append (get history component) {condition: new-condition, timestamp: (get-current-timestamp)}) 
              u10
            )
          )
        }
      )
    )
    (ok true)
  )
)

;; Add inspection agency
(define-public (add-inspection-agency (agency principal) (inspection-type uint))
  (begin
    (asserts! (is-city-admin tx-sender) ERR_UNAUTHORIZED)
    (asserts! (is-valid-inspection-type inspection-type) ERR_INVALID_INSPECTION)
    
    (map-set inspection-agencies
      {agency: agency, inspection-type: inspection-type}
      {approved: true}
    )
    (ok true)
  )
)

;; Add inspection to component
(define-public (add-inspection (component-id uint) (inspection-type uint))
  (begin
    (asserts! (is-valid-component-id component-id) ERR_INVALID_COMPONENT)
    (asserts! (is-valid-inspection-type inspection-type) ERR_INVALID_INSPECTION)
    (asserts! (is-inspection-agency tx-sender inspection-type) ERR_UNAUTHORIZED)
    
    (asserts! 
      (is-none 
        (map-get? component-inspections {component-id: component-id, inspection-type: inspection-type})
      )
      ERR_INSPECTION_EXISTS
    )
    
    (map-set component-inspections
      {component-id: component-id, inspection-type: inspection-type}
      {
        inspector: tx-sender,
        timestamp: (get-current-timestamp),
        passed: true
      }
    )
    (ok true)
  )
)

;; Get component history
(define-read-only (get-component-history (component-id uint))
  (let 
    (
      (component (unwrap! (map-get? component-details {component-id: component-id}) ERR_INVALID_COMPONENT))
    )
    (ok (get history component))
  )
)

;; Get current component condition
(define-read-only (get-component-condition (component-id uint))
  (let 
    (
      (component (unwrap! (map-get? component-details {component-id: component-id}) ERR_INVALID_COMPONENT))
    )
    (ok (get current-condition component))
  )
)