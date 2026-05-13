;; This contract implements the SIP-009 community-standard Non-Fungible Token trait
(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)

;; Define the NFT
(define-non-fungible-token your-nft-name uint)

;; State
(define-data-var last-token-id uint u0)
(define-data-var base-uri (string-ascii 80) "https://your.api.com/path/to/collection/{id}")

;; Constants
(define-constant CONTRACT-OWNER tx-sender)
(define-constant COLLECTION-LIMIT u1000)

;; Standardized errors
(define-constant ERR-UNAUTHORIZED (err u100))
(define-constant ERR-NOT-TOKEN-OWNER (err u101))
(define-constant ERR-TOKEN-NOT-FOUND (err u102))
(define-constant ERR-SOLD-OUT (err u103))
(define-constant ERR-INVALID-RECIPIENT (err u104))

;; SIP-009: Get the last minted token ID
(define-read-only (get-last-token-id)
  (ok (var-get last-token-id))
)

;; SIP-009: Get token metadata URI
(define-read-only (get-token-uri (token-id uint))
  (match (nft-get-owner? your-nft-name token-id)
    owner (ok (some (var-get base-uri)))
    (ok none)
  )
)

;; SIP-009: Get the owner of a given token
(define-read-only (get-owner (token-id uint))
  (ok (nft-get-owner? your-nft-name token-id))
)

;; SIP-009: Transfer NFT token to another owner
(define-public (transfer
    (token-id uint)
    (sender principal)
    (recipient principal)
  )
  (begin
    (asserts! (is-eq contract-caller sender) ERR-UNAUTHORIZED)
    (asserts! (not (is-eq sender recipient)) ERR-INVALID-RECIPIENT)
    (asserts! (is-some (nft-get-owner? your-nft-name token-id)) ERR-TOKEN-NOT-FOUND)
    (asserts! (is-eq (unwrap! (nft-get-owner? your-nft-name token-id) ERR-TOKEN-NOT-FOUND) sender) ERR-NOT-TOKEN-OWNER)
    (nft-transfer? your-nft-name token-id sender recipient)
  )
)

;; Mint a new NFT
(define-public (mint (recipient principal))
  (let ((token-id (+ (var-get last-token-id) u1)))
    (asserts! (is-eq contract-caller CONTRACT-OWNER) ERR-UNAUTHORIZED)
    (asserts! (< (var-get last-token-id) COLLECTION-LIMIT) ERR-SOLD-OUT)
    (try! (nft-mint? your-nft-name token-id recipient))
    (var-set last-token-id token-id)
    (ok token-id)
  )
)

;; Update the base metadata URI
(define-public (set-base-uri (new-base-uri (string-ascii 80)))
  (begin
    (asserts! (is-eq contract-caller CONTRACT-OWNER) ERR-UNAUTHORIZED)
    (var-set base-uri new-base-uri)
    (ok true)
  )
)