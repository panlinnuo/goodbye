import { Int } from "@dfinity/candid/lib/cjs/idl";
import { goodbye_backend } from "../../declarations/goodbye_backend";

async function post() {
  let post_button = document.getElementById("post");
  let err = document.getElementById("error");
  err.innerText = "";
  post_button.ariaDisabled = true;
  let textarea = document.getElementById("message");
  let text = textarea.value;
  let pwd = document.getElementById("pwd").value;
  try { 
    await goodbye_backend.post(pwd, text);
    textarea.value = "";
  } catch (error) {
    console.error(error);
    err.innerText = "Failed";
  }
  post_button.ariaDisabled = false;
}

var num_posts = 0;
async function load_posts() {
  let posts_section = document.getElementById("posts");
  let posts = await goodbye_backend.posts(1);
  if (num_posts == posts.length) return;
  posts_section.replaceChildren([]);
  num_posts = posts.length;
  for(var i = num_posts - 1; i >= 0; i --) {
    let post = document.createElement("p");
    post.innerText = posts[i].author + " SAY: " +  posts[i].text + " - " + Date((BigInt(posts[i].time) / BigInt(1000000000))).toLocaleString(); 
    posts_section.appendChild(post);
  }
}

async function getName() {
  let get_button = document.getElementById("getName");
  get_button.disabled = true;
  let name = await goodbye_backend.get_name();
  document.getElementById("name").value = name;
  get_button.disabled = false;
}

async function setName() {
  let set_button = document.getElementById("setName");
  let info = document.getElementById("info");
  info.innerText = "";
  set_button.disabled = true;
  let nameIn = document.getElementById("name");
  let name = nameIn.value;
  try { 
    await goodbye_backend.set_name(name);
    nameIn.value = "";
    info.innerText = "Success";
  } catch (error) {
    console.error(error);
    info.innerText = "Failed";
  }
  set_button.disabled = false;
}

var num_follows = 0;
async function follows() {
  let follows = await goodbye_backend.follows();
  if (num_follows == follows.length) return;
  num_follows = follows.length;
  let info = "";
  for(var i = 0; i < num_follows; i ++) {
    let id = follows[i]['uid'];
    info += "<button class='info_btn' id= " + id + ">" + follows[i]['uname'] + "</button>";
    info += "<section id=" + id + "-msg" + "></section></br>";
  }
  document.getElementById("follow").innerHTML = info;
  for(var i = 0; i < num_follows; i ++) {
    let id = follows[i]['uid'];
    document.getElementById(id).addEventListener('click', function handleClick(event) {
      load_posts2(id);
    })
  }
}

var num_posts2 = 0;
async function load_posts2(id) {
  alert("Id: " + id + " , Please wait");
  let posts_section2 = document.getElementById(id + "-msg");
  try {
    let posts2 = await goodbye_backend.posts2(id, 1);
    if (num_posts2 == posts2.length) return;
    posts_section2.replaceChildren([]);
    num_posts2 = posts2.length;
    for(var i = num_posts2 - 1; i >= 0; i --) {
      let post2 = document.createElement("p");
      post2.innerText = posts2[i].author + " SAY: " +  posts2[i].text + " - " + Date((BigInt(posts2[i].time) / BigInt(1000000000))).toLocaleString(); 
      posts_section2.appendChild(post2);
    }
  } catch (error) {
    console.error(error);
  }
}

async function load() {
  let post_button = document.getElementById("post");
  post_button.onclick = post;
  load_posts();
  setInterval(load_posts, 5000);

  let get_button = document.getElementById("getName");
  get_button.onclick = getName;

  let set_button = document.getElementById("setName");
  set_button.onclick = setName;

  follows();
}

window.onload = load;
