package github

// Error represents an API error.
type Error struct {
	Message string `json:"message"`
}

func (e Error) Error() string  { return e.Message }
func (e Error) String() string { return e.Message }

// Branch represents a branch, including protection.
type Branch struct {
	RequiredStatusChecks       *RequiredStatusChecks       `json:"required_status_checks"`
	EnforceAdmins              bool                        `json:"enforce_admins"`
	RequiredPullRequestReviews *RequiredPullRequestReviews `json:"required_pull_request_reviews"`
	Restrictions               *Restrictions               `json:"restrictions"`
}

// RequiredStatusChecks status checks of protected branch
type RequiredStatusChecks struct {
	URL         string   `json:"url"`
	Strict      bool     `json:"strict"`
	Contexts    []string `json:"contexts"`
	ContextsURL string   `json:"contexts_url"`
}

// DismissalRestrictions object must have the following keys
type DismissalRestrictions struct {
	Users []string `json:"users"`
	Teams []string `json:"teams"`
}

// RequiredPullRequestReviews pull request review enforcement of protected branchEnabled for GitHub Apps
type RequiredPullRequestReviews struct {
	DismissalRestrictions   DismissalRestrictions `json:"dismissal_restrictions"`
	DismissStaleReviews     bool                  `json:"dismiss_stale_reviews"`
	RequireCodeOwnerReviews bool                  `json:"require_code_owner_reviews"`
}

// Restrictions restrict who can push to this branch.
type Restrictions struct {
	Users []string `json:"users"`
	Teams []string `json:"teams"`
}

// commentHook represents a subset of the issue_comment payload.
type commentHook struct {
	Issue struct {
		Link   string `json:"html_url"`
		Number int    `json:"number"`
		User   struct {
			Login string `json:"login"`
		} `json:"user"`

		PullRequest struct {
			Link string `json:"html_url"`
		} `json:"pull_request"`
	} `json:"issue"`

	Comment struct {
		Body string `json:"body"`
		User struct {
			Login string `json:"login"`
		} `json:"user"`
	} `json:"comment"`

	Repository struct {
		Name     string `json:"name"`
		FullName string `json:"full_name"`
		Desc     string `json:"description"`
		Private  bool   `json:"private"`
		Owner    struct {
			Login  string `json:"login"`
			Type   string `json:"type"`
			Avatar string `json:"avatar_url"`
		} `json:"owner"`
	} `json:"repository"`

	Review struct {
		ID   int `json:"id"`
		User struct {
			Login string `json:"login"`
			ID    int    `json:"id"`
		} `json:"user"`
		Body  string `json:"body"`
		State string `json:"state"`
	} `json:"review"`

	PullRequest struct {
		URL      string `json:"url"`
		ID       int    `json:"id"`
		IssueURL string `json:"issue_url"`
		Number   int    `json:"number"`
	} `json:"pull_request"`
}
