.PHONY: deploy run
deploy:
	rm -rf public/*
	hugo 
	cd public && git add :/ && git commit -am "publish" && git push origin master
run:
	hugo server -w
