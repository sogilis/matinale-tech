package main

import (
	"flag"
	"fmt"
	"net/http"
	"os"
)

var (
	env = flag.String("env", os.Getenv("ENV"), "test or production")
)

func main() {
	flag.Parse()
	fmt.Printf("starting a %s instance\n", *env)
	http.HandleFunc("/status", func(w http.ResponseWriter, r *http.Request) {
		w.WriteHeader(200)
	})

	fs := http.FileServer(http.Dir("www/"))
	prefix := fmt.Sprintf("/%s/", *env)
	http.Handle(prefix, http.StripPrefix(prefix, fs))
	http.Handle("/", fs)
	fmt.Printf("Listening on http://0.0.0.0%s\n", ":80")
	err := http.ListenAndServe(":80", nil)
	fmt.Println("leaving now the server : " + err.Error())
}
