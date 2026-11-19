.PHONY: deploy run hugo

run: 
	hugo server --watch --buildDrafts
preview:
	hugo server --watch
new:
	@read -p "Post file name: " name;\
	hugo new post/$$name.md
deploy:
	rm -rf public/*
	hugo 
	cd public && git add :/ && git commit --amend -am "publish" && git push origin master --force
