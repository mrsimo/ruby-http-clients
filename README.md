# Ruby HTTP Clients

This is my benchmark of ruby http client libraries. There are many like it, but this one is mine.

I started this project as way for me to easily test different setups and different ways of using
the various ruby http clients.

To run it just clone this repository and run `bundle install` on it. You can then call
`bin/benchmark` against an arbitrary URL. Run `bin/benchmark --help` for the different options.

Here's an example output:

```
$ bin/benchmark -n1000 -p https://localhost:3000/delay/5
x====================x====================x====================x====================x
|  1000 requests with persistent connection against https://localhost:3000/delay/5  |
x====================x====================x====================x====================x
|                    |      Average       |       Total        |                    |
x====================x====================x====================x====================x
| net/http           |             8.31ms |          8312.88ms | All OK             |
| Curb               |            34.09ms |         34094.54ms | All OK             |
| Typhoeus           |             8.02ms |          8015.22ms | All OK             |
| REST Client        |            39.12ms |         39118.06ms | All OK             |
| http.rb            |            11.74ms |         11742.39ms | All OK             |
| Excon              |             8.06ms |          8064.51ms | All OK             |
| Faraday+net/http   |            18.82ms |         18817.55ms | All OK             |
| Patron             |             8.20ms |          8198.87ms | All OK             |
x====================x====================x====================x====================x
```

Don't take these numbers as an official statement on how fast each client is. Each application is
different and your needs too. Keep reading this README for some more rambles.

## Contributing

I'd be very happy to include more clients here, or fix any issues in my implementations.

## `bin/benchmark` options

* `-n, --number N`: Specify how many requests to run in total for each client.
* `-p, --persistent`: Try to setup a persistent connection instead of individual requests.
* `-c, --concurrent`: Try to run requests in a concurrent way. With Typhoeus, for example, it will run with a maximum concurrency of 5.

## `bin/server-*`

You can easily boot a rails application to respond to these requests by running `bin/server-http` or `bin/server-https`. They'll
be available under `localhost:3000` using Puma. For https, the certificate is self-signed.

By default, this application does nothing, but you can pass a delay and it will sleep for the
specified number of milliseconds. Call `/delay/50` to have the request sleep for 50 milliseconds.

## Commentary

Each application is different. If you're doing one-off requests every now and then, these
performance metrics might not help you a lot. You're probably good enough using net/http or any
gem that wraps around it. Faraday is a very nice way to do that, but from what I've seen here,
you pay a small penalty. If the request is going to take 150ms, then 10 more ms on top won't make
much difference, so even that might be OK.

If you have to do many small requests, all to the same host, you should probably look into a library
that supports persistent connections. This would happen, for instance, if you're in a service-oriented
architecture, and each request to your service requires you to do one or more requests to other
services. This is even worse if that request has to go through https–a request that the server
might be able to put together in 5 or 10ms, might end up 50 to 60ms slower just because of TLS
negotiation. If you have a persistent connection you can avoid most of that.

And of course, concurrent requests are very important if you have to make multiple requests
at the same time. You can do N requests taking the time of the slowest one.
