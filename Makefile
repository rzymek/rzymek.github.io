.PHONY: deploy
deploy:
	hugo 
	cd public && git add :/ && git commit -am "publish" && git push origin master
