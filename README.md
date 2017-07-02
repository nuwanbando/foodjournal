# foodjournal

This is a sample food journal project done by ballerinalang.

The prject calls nutritionix food calorie API to get calroie information

to create a journal entry:

```
POST /foodlog/log HTTP/1.1
Host: localhost:9090
Content-Type: application/json
Cache-Control: no-cache

{
	"bf":"bigmac",
	"lunch":"rice",
	"dinner":"pizza"
}
```

to read the journal entries you can,

```
GET /foodlog/log/{limit} HTTP/1.1
Host: localhost:9090
Cache-Control: no-cache
```
