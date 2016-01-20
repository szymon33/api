# Sample cURL sessions

## Simple test header
```
curl -I http://api.example.com:3000
```

```
HTTP/1.1 200 OK
Content-Type: application/json; charset=utf-8
X-UA-Compatible: IE=Edge
ETag: "ba518e7bb13f1b9d72a0569a52fc2832"
Cache-Control: max-age=0, private, must-revalidate
X-Request-Id: cc7ee3ae31ea3d631c73d8f3e61f9d9e
X-Runtime: 0.115776
Connection: close
Server: thin
```
## Credentials
### Failing scenario
* Bad credentials
```
curl http://api.example.com:3000/posts
```

```json
Bad credentials
```

* Insufficient privileges
```
curl -X DELETE -u 'guest:123' http://api.example.com:3000/posts/1
```

```json
Insufficient privileges
```
or

```
curl -X DELETE -Iu 'guest:123' http://api.example.com:3000/posts/1
```

```json
HTTP/1.1 403 Forbidden
Content-Type: application/json; charset=utf-8
X-UA-Compatible: IE=Edge
Cache-Control: no-cache
Set-Cookie: _api_session=BAh7B0kiD3N...; path=/; HttpOnly
X-Request-Id: 493d5d35040d080f07e5a8697aabe485
X-Runtime: 0.006008
Connection: close
Server: thin
```

### Successful scenario
* Retrive all posts
```
curl -u 'gates:123' http://api.example.com:3000/posts
```

```json
[{"content":"Please allow me to disagree with what your subconscious might be telling you after reading the title of my article. I am neither arrogant nor egotistical.","created_at":"2016-01-19T16:55:36Z","id":2,"like_counter":0,"title":"12 Reasons Why I Won\u2019t Add You To My LinkedIn Connections","updated_at":"2016-01-19T16:55:36Z","user_id":3},{"content":"Do you describe yourself differently -- on your website, promotional materials, or especially on social media -- than you do in person? Do you use cheesy clich\u00e9s and overblown superlatives and breathless adjectives? Do you write things about yourself you would never have the nerve to actually say?","created_at":"2016-01-19T16:55:36Z","id":1,"like_counter":1,"title":"Stop Using These 16 Terms to Describe Yourself","updated_at":"2016-01-19T16:55:36Z","user_id":2}]
```
* Admin reads just header
```
curl -IH "Accept: application/json" -u 'jobs:123' http://api.example.com:3000/posts
```

```json
HTTP/1.1 200 OK
Content-Type: application/json; charset=utf-8
X-UA-Compatible: IE=Edge
ETag: "30290383bf8a6b7ffa5056a89237b520"
Cache-Control: max-age=0, private, must-revalidate
Set-Cookie: _api_session=BAh7B0kiD3Nlc3Np...; path=/; HttpOnly
X-Request-Id: 3795240c2eb24f39cb82416e72aa88b6
X-Runtime: 0.005976
Connection: close
Server: thin
```
* Guest reads one comment
```
curl -u 'guest:123' http://api.example.com:3000/posts/1/comments/1
```

```json
{"content":"Content is this and that and don't forget to say it's great!","created_at":"2016-01-19T16:55:36Z","id":1,"like_counter":0,"post_id":1,"updated_at":"2016-01-19T16:55:36Z","user_id":3}
```
