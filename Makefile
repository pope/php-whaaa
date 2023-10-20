vendor:
	composer install

php/posts.json: posts.json
	cp posts.json php/posts.json

php-fast/posts.json: posts.json
	cp posts.json php-fast/posts.json

go/posts.json: posts.json
	cp posts.json go/posts.json

go/php-whaaa: go/main.go
	cd go && go build -pgo=auto

rust/target/release/php-whaaa: rust/src/main.rs rust/Cargo.toml rust/Cargo.lock
	cd rust && cargo build --release

run-php: php/posts.json
	cd php && php -S 127.0.0.1:8001

run-php-fast: php-fast/posts.json vendor
	cd php-fast && php index.php

run-go: go/php-whaaa go/posts.json
	cd go && ./php-whaaa

run-rust: rust/target/release/php-whaaa
	./rust/target/release/php-whaaa

benchmark:
	plow -c 20 -n 100000 http://127.0.0.1:8001

clean:
	rm go/php-whaaa go/posts.json php/posts.json
	cd rust && cargo clean
