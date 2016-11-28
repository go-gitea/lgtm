package template

//go:generate go-bindata -pkg template -o bindata.go files/
//go:generate go fmt bindata.go
//go:generate sed -i.bak "s/Html/HTML/" bindata.go
//go:generate rm bindata.go.bak

import (
	"encoding/json"
	"html/template"
	"path/filepath"
)

// Template is a template handler for the used templates.
func Template() *template.Template {
	funcs := map[string]interface{}{
		"json": marshal,
	}

	dir, _ := AssetDir("files")
	tmpl := template.New("_")
	tmpl.Funcs(funcs)

	for _, name := range dir {
		path := filepath.Join("files", name)
		src := MustAsset(path)
		tmpl = template.Must(
			tmpl.New(name).Parse(string(src)),
		)
	}

	return tmpl
}

// marshal is a helper function to render data as JSON
// inside the template.
func marshal(v interface{}) template.JS {
	a, _ := json.Marshal(v)
	return template.JS(a)
}
