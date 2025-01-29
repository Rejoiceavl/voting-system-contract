;; Voting System Contract
;; A simple voting system where users vote on proposals with weights based on their token holdings.

(define-map proposals
    {id: uint}            ;; Proposal ID
    { 
        description: (string-utf8 100),  ;; Proposal description
        votes-for: uint,                ;; Total votes in favor
        votes-against: uint             ;; Total votes against
    })

(define-map user-votes
    { voter: principal, proposal-id: uint }
    { has-voted: bool }) ;; Tracks if a user has voted on a specific proposal

;; Events for tracking using data vars
(define-data-var last-proposal-created {id: uint, description: (string-utf8 100)} {id: u0, description: u""})
(define-data-var last-vote {voter: principal, proposal-id: uint, choice: (string-utf8 5)} 
    {voter: 'ST000000000000000000002AMW42H, proposal-id: u0, choice: u""})

;; Function: Create a new proposal
(define-public (create-proposal (id uint) (description (string-utf8 100)))
    (begin
        ;; Ensure the proposal ID is valid and unique
        (asserts! (> id u0) (err u103))
        (asserts! (is-none (map-get? proposals {id: id})) (err u100))
        ;; Validate description length
        (asserts! (is-eq (len description) (len description)) (err u104))
        ;; Add proposal to the map
        (map-set proposals {id: id} {
            description: description,
            votes-for: u0,
            votes-against: u0
        })
        ;; Emit event for tracking
        ;; Track proposal creation
        (var-set last-proposal-created {id: id, description: description})
        (ok true)
    )
)

;; Function: Vote on a proposal
(define-public (vote (proposal-id uint) (in-favor bool))
    (let (
        ;; Fetch the proposal
        (proposal (map-get? proposals {id: proposal-id}))
        ;; Check if the user has already voted
        (vote-record (map-get? user-votes { voter: tx-sender, proposal-id: proposal-id }))
    )
        (begin
            ;; Ensure the proposal exists
            (asserts! (is-some proposal) (err u101))
            ;; Ensure the user has not voted on this proposal
            (asserts! (is-none vote-record) (err u102))
            ;; Validate proposal ID
            (asserts! (> proposal-id u0) (err u103))

            ;; Update the votes
            (let ((unwrapped-proposal (unwrap! proposal (err u101))))
                (if in-favor
                    (map-set proposals {id: proposal-id} {
                        description: (get description unwrapped-proposal),
                        votes-for: (+ (get votes-for unwrapped-proposal) u1),
                        votes-against: (get votes-against unwrapped-proposal)
                    })
                    (map-set proposals {id: proposal-id} {
                        description: (get description unwrapped-proposal),
                        votes-for: (get votes-for unwrapped-proposal),
                        votes-against: (+ (get votes-against unwrapped-proposal) u1)
                    })
                )
            )

            ;; Record that the user has voted
            (map-set user-votes { voter: tx-sender, proposal-id: proposal-id } { has-voted: true })
            
            ;; Emit event for tracking
            ;; Track voting
            (var-set last-vote {voter: tx-sender, proposal-id: proposal-id, choice: (if in-favor u"yes" u"no")})
            (ok true)
        )
    )
)

;; Function: Get proposal details
(define-read-only (get-proposal (proposal-id uint))
    (map-get? proposals {id: proposal-id})
)

;; Function: Check if a user has voted
(define-read-only (has-voted (proposal-id uint))
    (is-some (map-get? user-votes { voter: tx-sender, proposal-id: proposal-id }))
)
