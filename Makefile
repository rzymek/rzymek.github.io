.PHONY: run preview new

run:
	hugo server --watch --buildDrafts
preview:
	hugo server --watch
new:
	@read -p "Post file name: " name;\
	hugo new post/$$name.md
