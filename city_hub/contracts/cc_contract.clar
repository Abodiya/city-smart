;; SmartCityInfrastructure Contract - Version 1
;; Basic infrastructure component registration and tracking

(define-trait city-infrastructure-basic-trait
  (
    (register-component (uint uint) (response bool uint))
    (update-component-condition (uint uint) (response bool uint))
    (get-component-condition (uint) (response uint uint))
  )
)

;; Define component condition constants
(define-constant CONDITION_NEW u1)
(define-constant CONDITION_OPERATIONAL u2)
(define-constant CONDITION_NEEDS_MAINTENANCE u3)
(define-constant CONDITION_UNDER_REPAIR u4)

;; Error constants
(define-constant ERR_UNAUTHORIZED (err u1))
(define-constant ERR_INVALID_COMPONENT (err u2))
(define-constant ERR_CONDITION_UPDATE_FAILED (err u3))
(define-constant ERR_INVALID_CONDITION (err u4))

;; Contract owner
(define-data-var city-admin principal tx-sender)

;; Infrastructure component tracking map
(define-map component-details 
  {component-id: uint} 
  {
    department: principal,
    current-condition: uint
  }
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

;; Validate component ID
(define-private (is-valid-component-id (component-id uint))
  (and (> component-id u0) (<= component-id u1000000))
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
        current-condition: initial-condition
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
      (merge component {current-condition: new-condition})
    )
    (ok true)
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