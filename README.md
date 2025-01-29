# Voting System Contract

A simple voting system where users vote on proposals with weights based on their token holdings. This contract includes functionality to track proposals and user votes.

## Features

- Create and manage proposals
- Vote on proposals with weighted votes based on token holdings
- Track user votes to prevent double voting

## Contract Details

### Proposals

Proposals are stored in a map with the following structure:

```clarity
(define-map proposals
    {id: uint}            ;; Proposal ID
    { 
        description: (string-utf8 100),  ;; Proposal description
        votes-for: uint,                ;; Total votes in favor
        votes-against: uint             ;; Total votes against
    })
