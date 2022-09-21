@RestResource(urlMapping='/api/webhooks/pushDetails/*')
global with sharing class webhookRestServices {
    public webhookRestServices() {

    }

    @HttpPost
    global static void handleRequest(){
        //Request
        try{
            RestRequest request = RestContext.request;
            RestResponse response = RestContext.response;

            String hashedval = request.headers.get('X-Hub-Signature-256');
            System.debug('Hashed Value -> '+hashedval);

            Blob body = request.requestBody;

            Blob hmac = Crypto.generateMac('hmacSHA256', body, Blob.valueOf('webhookSecret'));
            String hmacString = 'sha256='+EncodingUtil.convertToHex(hmac);
            // hashedval == hmacString

            JSONParser parser = JSON.createParser(body.toString());
            pusher ps;
            head_commit hc;
            String repo;
            while (parser.nextToken() !=null) {
                System.debug('@Parser Next Token@'+parser.nextToken());
                if(parser.getText() == 'pusher'){
                    System.debug('Pusher -> ');

                    parser.nextToken();
                    ps = (pusher)parser.readValueAs(pusher.class);
                    System.debug('@_'+ps);
                }
                if(parser.getText() == 'head_commit'){
                    System.debug('Head Commit');
                    
                    parser.nextToken();
                    hc = (head_commit)parser.readValueAs(head_commit.class);
                    System.debug('@_'+hc);
                }
                if(parser.getText() == 'full_name'){
                    System.debug('Full Name');

                    parser.nextToken();
                    repo = parser.getText();
                    System.debug('Full Name -> '+repo);
                }
            }
            try{
                Account acc= new Account();
                acc.Name = hc.message;
                acc.File_Ids__c = ps.email +' Full Name '+ repo;
                insert acc;
                response.statusCode = 200;
                response.responseBody = Blob.valueOf(JSON.serialize(new SFDCResponse('Success','Account Created')));
            }catch(Exception e){
                response.statusCode = 401;
                response.responseBody = Blob.valueOf(JSON.serialize(new SFDCResponse('Error',e.getMessage()+ ' - hc -'+hc+'- ps -'+ps+' - repo - '+repo)));
            }
        }catch(Exception e){
            System.debug('Exception -> '+e.getMessage());
        }
        
    }

    public class SFDCResponse{
        String response;
        String message;
        public SFDCResponse(String res, String msg){
            this.response = res;
            this.message = msg;
        }
    }
    public class pusher{
        public String name;
        public String email;
        public pusher(String name, String email){
            this.name = name;
            this.email = email;
        }
    }
    public class author{
        public String name;
            public String email;
            public string username;
            public author(String name, String email, string username){
                    name = name;
                    email = email;
                    username = username;
            } 
    }
    public class committer{
        public String name;
        public String email;
        public string username;
        public committer(String name, String email, String username){
                name = name;
                email = email;
                username = username;
        } 
    }

    public class head_commit{
        public String id;
        public String tree_id;
        public String distinct;
        public String message;
        public String timestamp;
        public String url;
        public author autr;
        public committer comiter;
        public List<String> added;
        public List<String> removed;
        public List<String> modified;

        public head_commit(String id,String tree_id,String distinct,String message,String timestamp,String url,author autr,committer comiter,List<String> added,List<String> removed,List<String> modified){
            //set values
            id = id;
            tree_id = tree_id;
            distinct = distinct;
            message = message;
            timestamp = timestamp;
            url = url;
            autr    = autr;
            comiter = comiter;
            added = added;
            removed  = removed;
            modified = modified;
        }
    }
}

