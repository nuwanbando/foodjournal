# Bandos' Food Journal Project

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

the reponse for the POST will look like
```
{
    "breakfast": {
        "item": "bigmac",
        "calories": 562.83
    },
    "lunch": {
        "item": "rice",
        "calories": 205.4
    },
    "dinner": {
        "item": "pizza",
        "calories": 2268.98
    },
    "total_calories": 3037.21,
    "date": "Jul 2 2017"
}
```

to read the journal entries you can,

```
GET /foodlog/log/{limit} HTTP/1.1
Host: localhost:9090
Cache-Control: no-cache
```

the response wood look like:
```
{
    "results": [
        {
            "id": 2,
            "log": "{\"breakfast\":{\"item\":\"bigmac\",\"calories\":562.83},\"lunch\":{\"item\":\"rice\",\"calories\":205.4},\"dinner\":{\"item\":\"pizza\",\"calories\":2268.98},\"total_calories\":3037.21,\"date\":\"Jul 2 2017\"}"
        },
        {
            "id": 1,
            "log": "{\"breakfast\":{\"item\":\"oats\",\"calories\":606.84},\"lunch\":{\"item\":\"rice\",\"calories\":205.4},\"dinner\":{\"item\":\"pasta\",\"calories\":169.06},\"total_calories\":981.3,\"date\":\"Jul 2 2017\"}"
        }
    ]
}
```

Currently there are some JSON parsing issues, which is reported at ballerinalang

The ballerina sequence for the above is like:

![Alt text](https://cdn.rawgit.com/nuwanbando/foodjournal/master/foodlog.svg)

