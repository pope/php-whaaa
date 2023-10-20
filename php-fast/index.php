<?php
require __DIR__ . '/../vendor/autoload.php';

use OpenSwoole\HTTP\Request;
use OpenSwoole\HTTP\Response;
use OpenSwoole\HTTP\Server;

$server = new Server('0.0.0.0', 8001);

$server->on('start', function (Server $server) {
	echo "Server is started at http://0.0.0.0:8001\n";
});

$server->on('request', function (Request $request, Response $response) {
	$data = json_decode(file_get_contents(__DIR__ . '/posts.json'));

	$items = array_map(function ($item) {
		return ['id' => $item->id, 'title' => ucwords($item->title)];
	}, $data->posts);

	$response->header('Content-Type', 'application/json');
	$response->end(json_encode($items));
});

$server->start();
