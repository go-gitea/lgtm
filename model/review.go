package model

import (
	"strings"
)

// Review represents a pull request review comment from the the remote API.
type Review struct {
	Author string
	Body   string
	State  string
}

// IsApproved check review state
func (r *Review) IsApproved() bool {
	return strings.ToLower(r.State) == "approved"
}
