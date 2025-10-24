;; Loyalty Cashback Program Smart Contract

;; Constants
(define-constant program-director tx-sender)
(define-constant err-director-only (err u100))
(define-constant err-cashback-redeemed (err u101))
(define-constant err-not-member (err u102))
(define-constant err-no-balance (err u103))
(define-constant err-redemption-closed (err u104))
(define-constant err-invalid-customer (err u105))
(define-constant err-invalid-balance (err u106))

;; Data Variables
(define-data-var total-cashback-reserve uint u5000000)
(define-data-var redemption-open bool false)

;; Data Maps
(define-map customer-balances principal uint)        ;; Maps customers to cashback balance
(define-map redemption-history principal bool)       ;; Tracks redemption status
(define-map premium-members principal bool)          ;; Premium membership status
(define-map registered-customers principal bool)     ;; Registered customer list

;; Private Functions
(define-private (is-program-director)
    (is-eq tx-sender program-director))

(define-private (is-valid-member (customer principal))
    (and 
        (is-some (map-get? registered-customers customer))
        (is-some (map-get? premium-members customer))))

(define-private (validate-customer (customer principal))
    (and
        (is-some (some customer))
        (not (is-eq customer program-director))))

;; Public Functions

;; Register customer (director only)
(define-public (register-customer (customer principal))
    (begin
        (asserts! (is-program-director) err-director-only)
        (asserts! (validate-customer customer) err-invalid-customer)
        (ok (map-set registered-customers customer true))))

;; Unregister customer (director only)
(define-public (unregister-customer (customer principal))
    (begin
        (asserts! (is-program-director) err-director-only)
        (asserts! (validate-customer customer) err-invalid-customer)
        (ok (map-set registered-customers customer false))))

;; Set premium membership (director only)
(define-public (set-premium-status (customer principal) (is-premium bool))
    (begin
        (asserts! (is-program-director) err-director-only)
        (asserts! (validate-customer customer) err-invalid-customer)
        (ok (map-set premium-members customer is-premium))))

;; Set cashback balance (director only)
(define-public (set-cashback-balance (customer principal) (balance uint))
    (begin
        (asserts! (is-program-director) err-director-only)
        (asserts! (validate-customer customer) err-invalid-customer)
        (asserts! (> balance u0) err-invalid-balance)
        (asserts! (<= balance (var-get total-cashback-reserve)) err-invalid-balance)
        (ok (map-set customer-balances customer balance))))

;; Redeem cashback (public)
(define-public (redeem-cashback)
    (let ((customer tx-sender)
          (cashback-balance (unwrap! (map-get? customer-balances customer) err-no-balance)))
        (begin
            (asserts! (var-get redemption-open) err-redemption-closed)
            (asserts! (is-valid-member customer) err-not-member)
            (asserts! (not (default-to false (map-get? redemption-history customer))) err-cashback-redeemed)
            (map-set redemption-history customer true)
            (ok cashback-balance))))

;; Batch cashback assignment (director only)
(define-public (batch-assign-cashback (customers (list 200 principal)) (balances (list 200 uint)))
    (begin
        (asserts! (is-program-director) err-director-only)
        (asserts! (is-eq (len customers) (len balances)) err-invalid-balance)
        (asserts! 
            (fold and 
                (map validate-customer customers) 
                true) 
            err-invalid-customer)
        (asserts! 
            (fold and 
                (map is-valid-balance balances)
                true) 
            err-invalid-balance)
        (ok true)))

(define-private (is-valid-balance (balance uint))
    (> balance u0))

;; Toggle redemption window (director only)
(define-public (toggle-redemption)
    (begin
        (asserts! (is-program-director) err-director-only)
        (ok (var-set redemption-open (not (var-get redemption-open))))))

;; Read-only functions

(define-read-only (get-cashback-balance (customer principal))
    (default-to u0 (map-get? customer-balances customer)))

(define-read-only (has-redeemed (customer principal))
    (default-to false (map-get? redemption-history customer)))

(define-read-only (check-membership (customer principal))
    (is-valid-member customer))

(define-read-only (is-redemption-open)
    (var-get redemption-open))

(define-read-only (get-total-reserve)
    (var-get total-cashback-reserve))

(define-read-only (get-customer-profile (customer principal))
    {
        cashback: (get-cashback-balance customer),
        redeemed: (has-redeemed customer),
        valid-member: (check-membership customer),
        registered: (default-to false (map-get? registered-customers customer)),
        premium: (default-to false (map-get? premium-members customer)),
        can-redeem: (and 
            (var-get redemption-open)
            (check-membership customer)
            (not (has-redeemed customer))
            (> (get-cashback-balance customer) u0)
        )
    })