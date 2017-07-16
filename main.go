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
	mux := http.NewServeMux()
	mux.HandleFunc(fmt.Sprintf("/%s", *env), func(w http.ResponseWriter, r *http.Request) {
		w.Write([]byte("Je suis en version 1"))
	})
	mux.HandleFunc("/status", func(w http.ResponseWriter, r *http.Request) {
		w.WriteHeader(200)
	})
	h := &http.Server{Addr: ":80", Handler: mux}
	fmt.Printf("Listening on http://0.0.0.0%s\n", ":80")
	err := h.ListenAndServe()
	fmt.Println("leaving now the server : " + err.Error())
}
