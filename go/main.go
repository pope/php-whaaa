package main

import (
	"log"
	"net/http"
	_ "net/http/pprof"
	"os"

	"github.com/goccy/go-json"
	"golang.org/x/text/cases"
	"golang.org/x/text/language"
)

type PostDocument struct {
	Posts []Post `json:"posts"`
}

type Post struct {
	Id    int    `json:"id"`
	Title string `json:"title"`
}

func main() {
	http.HandleFunc("/", func(w http.ResponseWriter, _ *http.Request) {
		jsonData, err := os.ReadFile("./posts.json")
		if err != nil {
			http.Error(w, "Failed to read JSON data", http.StatusInternalServerError)
			return
		}
		var doc PostDocument
		if err := json.Unmarshal(jsonData, &doc); err != nil {
			http.Error(w, "Failed to parse JSON data", http.StatusInternalServerError)
			return
		}

		outputPosts := make([]Post, 0, len(doc.Posts))
		for _, post := range doc.Posts {
			title := cases.Title(language.English)

			var newPost Post
			newPost.Id = post.Id
			newPost.Title = title.String(post.Title)
			outputPosts = append(outputPosts, newPost)
		}

		w.Header().Set("Content-Type", "application/json")

		if err := json.NewEncoder(w).Encode(outputPosts); err != nil {
			http.Error(w, "Failed to serialize JSON data", http.StatusInternalServerError)
			return
		}
	})

	log.Fatal(http.ListenAndServe(":8001", nil))
}
