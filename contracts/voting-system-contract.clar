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

