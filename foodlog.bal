import ballerina.net.http;
import ballerina.lang.messages;
import ballerina.lang.system;
import ballerina.lang.jsons;

import ballerina.data.sql;
import ballerina.lang.time;
import ballerina.lang.datatables;

@http:config { basePath: "/foodlog"}
service<http> FoodLog {

    @http:GET {}
    @http:Path { value: "/log/{limit}"}
    resource Resource1 (message m, @http:PathParam{value:"limit"} string limit) {
        json results = readLog(limit);
        system:println("GET called");
        message response = {};
        messages:setJsonPayload(response, results);
        reply response;
    }

    @http:POST {}
    @http:Path { value: "/log"}
    resource log (message m) {
        system:println("POST called");
        //format: https://api.nutritionix.com/v1_1/search/cheddar%20cheese?fields=item_name%2Citem_id%2Cbrand_name%2Cnf_calories%2Cnf_total_fat&appId=[YOURID]&appKey=[YOURKEY]
        string nutritionixURL = "https://api.nutritionix.com/v1_1/search/";
        string appId = "0df5f4a4";
        string accessToken = "44081cffefd37ac6cc41e8b4d6241faf";
        string path = "?fields=item_name%2Citem_id%2Cbrand_name%2Cnf_calories%2Cnf_total_fat&appId="+ appId + "&appKey=" + accessToken;
        
        http:ClientConnector nutritionixEP = create http:ClientConnector(nutritionixURL);
        
        json whatIAteToday = messages:getJsonPayload(m);
        
        
        fork {
            worker fetchBf {
                system:log(4,"invoking worker for breakfast");
                message response = http:ClientConnector.get(nutritionixEP, jsons:toString(whatIAteToday.bf) + path, m);
                json weightOfbf = messages:getJsonPayload(response);
                json bf = {"item": whatIAteToday.bf,"calories" : weightOfbf.hits[0].fields.nf_calories};
                bf ->fork;

            }
            worker fetchLunch {
                system:log(4,"invoking worker for lunch");
                message response = http:ClientConnector.get(nutritionixEP, jsons:toString(whatIAteToday.lunch) + path, m);
                json weightOfLunch = messages:getJsonPayload(response);
                json lunch = {"item": whatIAteToday.lunch,"calories" : weightOfLunch.hits[0].fields.nf_calories};
                lunch ->fork;
            }
            worker fetchDinner {
                system:log(4,"invoking worker for dinner");
                message response = http:ClientConnector.get(nutritionixEP, jsons:toString(whatIAteToday.dinner) + path, m);
                json weightOfDinner = messages:getJsonPayload(response);
                json dinner = {"item": whatIAteToday.dinner,"calories" : weightOfDinner.hits[0].fields.nf_calories};
                dinner ->fork;
            }
        } join (all) (map vars) {
            any[] var1; any[] var2; any[] var3;
            
            var1,_ = (any[]) vars["fetchBf"];
            var2,_ = (any[]) vars["fetchLunch"];
            var3,_ = (any[]) vars["fetchDinner"];
            
            json breakfast; json lunch; json dinner;
            breakfast,_ = (json) var1[0];
            lunch,_ = (json) var2[0];
            dinner,_ = (json) var3[0];
            
            //system:print("bf: "+ jsons:toString(breakfast) + " lunch: " + jsons:toString(lunch) + " Dinner: " + jsons:toString(dinner));
            
            float bfc = 0.0; float lc = 0.0; float dc = 0.0;
            bfc,_ = (float)breakfast.calories;
            lc,_ = (float)lunch.calories;
            dc,_ =  (float)dinner.calories;
            
            float total = bfc + lc + dc;
            
            string today = time:format(time:currentTime(),"MMM d yyyy");
            
            json dayslog = {"breakfast": breakfast,"lunch" : lunch,"dinner" : dinner,"total_calories": total,"date" : today};
            
            message response = {};
            messages:setJsonPayload(response,dayslog);
            createLog(dayslog);

            reply response;
        }
        
    }
}

map dbprops = {"jdbcUrl":"jdbc:mysql://mysql.storage.cloud.wso2.com:3306/fooddiary_wso2demo4574","username":"nuwan_rACKhawA","password":"foodie"};

function createLog(json log) {
    sql:ClientConnector foodlog = create sql:ClientConnector(dbprops);
    string data = jsons:toString(log);

    sql:Parameter[] params = [];
    sql:Parameter para1 = {sqlType:"varchar",value:data};
    params = [para1];
    
    int ret = sql:ClientConnector.update (foodlog, "Insert into log (log) values (?)", params);
        
    system:log(4,"db record created status:: " + ret);
    foodlog.close();
}

function readLog(string limit) (json){
    
    sql:ClientConnector foodlog = create sql:ClientConnector(dbprops);
    sql:Parameter[] params = [];
    sql:Parameter para1 = {sqlType:"integer",value:limit};
    params = [para1];
    
    datatable dt = sql:ClientConnector.select(foodlog, "select * from log ORDER BY id DESC LIMIT ?", params);
    var logObj,err = <json>dt;
    
    json p = {};
    datatables:close(dt);
    
    foodlog.close();
    
    json results = {};
    jsons:addToObject(results, "$", "results", logObj);

    return results;
}
