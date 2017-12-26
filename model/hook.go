package model

// Hook represents a hook from the remote API.
type Hook struct {
	Repo    *Repo
	Issue   *Issue
	Comment *Comment
	Review  *Review
}
