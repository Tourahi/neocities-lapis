
build:
	git add .
	moonc "secret/secret.moon"
	git ls-files | grep '\.moon' | xargs moonc


clean:
	git add .
	rm "secret/secret.lua"
	git ls-files | grep '\.lua' | xargs rm
