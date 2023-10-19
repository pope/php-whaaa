<?php

$data = json_decode(file_get_contents(__DIR__ . '/posts.json'));

$items = array_map(function ($item) {
	return ['id' => $item->id, 'title' => ucwords($item->title)];
}, $data->posts);

header('Content-Type: application/json');
echo json_encode($items);

exit();
