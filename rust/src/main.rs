use std::net::SocketAddr;

use http_body_util::Full;
use hyper::{
	body::Bytes, server::conn::http1, service::service_fn, Request, Response,
};
use hyper_util::rt::TokioIo;
use serde::{Deserialize, Serialize};
use titlecase::titlecase;
use tokio::net::TcpListener;

#[derive(Serialize, Deserialize)]
struct PostCollection {
	posts: Vec<Post>,
}

#[derive(Serialize, Deserialize)]
struct Post {
	id: i64,
	title: String,
}

async fn index(
	_: Request<hyper::body::Incoming>,
) -> anyhow::Result<Response<Full<Bytes>>> {
	// let json = tokio::fs::read_to_string("posts.json").await?;
	let json = std::fs::read_to_string("posts.json")?;
	let doc: PostCollection = serde_json::from_str(&json)?;
	let posts = doc
		.posts
		.into_iter()
		.map(|p| Post {
			id: p.id,
			title: titlecase(&p.title),
		})
		.collect::<Vec<_>>();
	let posts_json = serde_json::to_string(&posts)?;

	Ok(Response::builder()
		.header("Content-Type", "application/json")
		.body(Full::new(Bytes::from(posts_json)))
		.unwrap())
}

#[tokio::main]
async fn main() -> anyhow::Result<()> {
	let addr = SocketAddr::from(([127, 0, 0, 1], 8001));

	let listener = TcpListener::bind(addr).await?;

	loop {
		let (stream, _) = listener.accept().await?;

		let io = TokioIo::new(stream);

		tokio::task::spawn(async move {
			if let Err(err) = http1::Builder::new()
				.serve_connection(io, service_fn(index))
				.await
			{
				println!("Error serving connection: {:?}", err);
			}
		});
	}
}
