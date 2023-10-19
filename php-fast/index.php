<?php
require __DIR__ . '/../vendor/autoload.php';

$server = new OpenSwoole\HTTP\Server('127.0.0.1', 8001);

$server->on('start', function (OpenSwoole\HTTP\Server $server) {
	echo "Server is started at http://127.0.0.1:8001\n";
});

$server->on('request', function (OpenSwoole\HTTP\Request $request, OpenSwoole\HTTP\Response $response) {
	$data = json_decode(file_get_contents(__DIR__ . '/posts.json'));

	$items = array_map(function ($item) {
		return ['id' => $item->id, 'title' => ucwords($item->title)];
	}, $data->posts);

	$response->header('Content-Type', 'application/json');
	$response->end(json_encode($items));
});

$server->start();
