
build:
	git add .
	git ls-files | grep '\.moon' | xargs moonc


clean:
	git add .
	git ls-files | grep '\.lua' | xargs rm
