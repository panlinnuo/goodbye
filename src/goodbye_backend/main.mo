import List "mo:base/List";
import Iter "mo:base/Iter";
import Principal "mo:base/Principal";
import Time "mo:base/Time";
import Nat "mo:base/Nat";

actor {
  public type Message = {
    author: ?Text;
    text: Text; 
    time: Time.Time;
  };

  public type User  = {
    uid: Principal;
    uname: ?Text;
  };

  var king: Text = "Linnuo";

  public type Microblog = actor {
    follow: shared(Principal) -> async (); // add关注对象
    follows: shared query () -> async [User]; // return关注对象列表
    post: shared (Text) -> async (); // 发布新消息
    posts: shared (Time.Time) -> async [Message]; // return 发布消息列表
    posts2: shared (Text) -> async [Message]; // return 所有关注对象发布的消息
    timeline: shared (Time.Time) -> async [Message]; // return 所有关注对象发布的消息
    set_name: shared (Text) -> async ();  // set 名字
    get_name: shared query () -> async ?Text; // get 名字
    unfollow: shared () -> async ();  // 清空跟随
  };

  // stable 修饰：升级不清空内存
  stable var followed : List.List<User> = List.nil();

  public shared func follow(id: Principal) : async (){
    let canister : Microblog = actor(Principal.toText(id));
    let name: ?Text = await canister.get_name();
    let u = {
      uid = id;
      uname = name;
    };
    followed := List.push(u, followed);
  };

  public shared query func follows() : async [User] {
    List.toArray(followed);
  };

  stable var messages : List.List<Message> = List.nil();

  // （msg）：获取消息属性
  public shared (msg) func post(pwd: Text, text: Text) : async (){
    // 获取发送者: dfx identity get-principal
    // assert(Principal.toText(msg.caller) == "vw7ov-537vk-abslh-s2gx7-gw2ff-v4u6y-thlcs-hejxf-hkkc5-bjiq7-pqe"); //消息发送者
    assert(pwd == "qwe123");
    let m = {
      author = ?king;
      text = text;
      time = Time.now();
    };
    messages := List.push(m, messages);
    // 用钱包调用正常返回失败：dfx canister --wallet=$(dfx identity get-wallet) call microblog_backend post "(\"Second post\")"
  };

  public shared func posts(since: Time.Time) : async [Message] {
    var list : List.List<Message> = List.nil();

    for (m in Iter.fromList(messages)) {
      if (m.time >= since){
        list := List.push(m, list);
      }
    };

    List.toArray(list);
  };

  public shared func posts2(pid: Principal, since: Time.Time) : async [Message] {
    try {
      let canister : Microblog = actor(Principal.toText(pid));
      await canister.posts(since);
    } catch (err) {
      []
    }
  };

  public shared func timeline(since: Time.Time) : async [Message] {
    var all : List.List<Message> = List.nil();

    for (user in Iter.fromList(followed)){
      let canister : Microblog = actor(Principal.toText(user.uid));
      let msgs = await canister.posts(since);

      for(msg in Iter.fromArray(msgs)){
        all := List.push(msg, all);
      };
    };

    List.toArray(all);
  };

  public shared func set_name(name: Text) {
    king := name;
  };

  public shared query func get_name() : async ?Text {
    return ?king;
  };

  public shared func unfollow() : async (){
    followed := List.nil();
  };

  // 发送消息：id和名称可以呼唤
  //  dfx canister call rrkah-fqaaa-aaaaa-aaaaq-cai post "(\"First post\")"   // 用Id发消息
  //  dfx canister call microblog_backend post "(\"Second post\")"            // 用名称发消息
  //  dfx canister call rrkah-fqaaa-aaaaa-aaaaq-cai posts "()"                // 获取消息列表
  //  dfx canister call microblog_backend2 follow "(principal \"$(dfx canister id microblog_backend)\")"  // 添加关注对象
  //  dfx canister call microblog_backend2 follows "()"                       // 获取关注对象列表
  //  dfx canister call microblog_backend2 timeline  "()"                     // 获取所有关注对象发布的消息
};
