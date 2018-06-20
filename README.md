# 20180620_Day9

#### 오전 퀴즈

- MVC 패턴에서 각각의 역할을 단어로 정의하기

### 다음 카페 만들기

- Session(Login)



### 간단과제

- BoardController는 완성했음
- User 모델과 UserController CRUD
  - columns: user_id, password, ip_address
  - show에서는 user_id와 ip_address만 보이게(pw제외)
  - delete는 없음
  - /user/new -> /sign_up
- Cafe 모델과 CafeController CRUD
  - columns: title, description
- View 까지!!!!
  - bootstrap4



### 기존과 같다! 그리고 다르다!

- 기존의 코드를 활용하여 model과 controller를 구성하는 코드는 동일하다. 이번 시간에는 route를 조금 더 RESTful 하게 바꿔보도록 하자.

*config/routes.rb*

```ruby
Rails.application.routes.draw do
    root 'board#index'
    get '/boards' => 'board#index' 
    get '/board/new' => 'board#new'
    get '/board/:id' => 'board#show'
    post '/boards' => 'board#create'
    get '/board/:id/edit' => 'board#edit'
    put '/board/:id' => 'board#update'
    patch '/board/:id' => 'board#update'
    delete '/board/:id' => 'board#destroy'
end
```

- 같은 url도 요청 방식에 따라 다른 action을 수행하게끔 할 수 있다. 현재까지 구현한 라우팅 중에 가장 RESTful한 형태이다. 
- 등록은 post, 수정은 put과 patch, 삭제는 delete, 조회는 get 방식으로 요청하게끔 라우팅을 구성하였다.
- 위와 같은 요청을 수행하기 위해서 일부 view 코드를 수정해야한다.

*app/views/board/edit*

```erb
<%= form_tag("/user/#{@user.id}", method: "PATCH") do %>
    <%= text_field_tag(:user_id, @user.user_id, readonly: true) %>
    <%= password_field_tag(:password) %>
    <%= submit_tag("가입하기") %>
<% end %>
```

- 수정의 경우 put과 patch 방식으로 요청을 받도록 되어 있는데 일부 브라우저에서 patch 방식을 지원하지 않는 경우가 있다. 위 코드로 작성된 html 코드는 다음과 같다.

```html
<form action="/board/2" accept-charset="UTF-8" method="post">
    <input name="utf8" type="hidden" value="✓">
    <input type="hidden" name="_method" value="patch">
    <input type="hidden" name="authenticity_token" value="tzziBXys6XXXVv6j/el+XNFK6uO8VbS0j75jtQWbV6k6DPD1pDq+N9QuLQjJz1myPudciv+wIThGU1uarbw1lA==">
    <input type="text" name="title" id="title" value="ㅁㄴㅇㄹ">
    <textarea name="contents" id="contents">ㅁㄴㅇㄹ</textarea>
    <input type="submit" name="commit" value="수정하기" data-disable-with="수정하기">
</form>
```

- 실제로 `form`태그의 method가 patch로 바뀌는 것이 아니라 다른 파라미터로 patch 방식이라고 넘어가게 된다.
- 삭제를 위한 delete의 요청 방식은 다음과 같이 구현할 수 있다.

```erb
<h2><%= @post.title %></h2>
<hr>
<p><%= @post.contents %></p>
<%= link_to "목록", "/" %>
<%= link_to "수정", "/board/#{@post.id}/edit" %>
<%= link_to "삭제", "/board/#{@post.id}", method: "delete" %>
```

- `link_to` 는 지난 시간에 배웠던 view helper 이다. 위와같이 작성하면 다음과 같은 html코드가 나온다.

```html
...
<h2>ㅁㄴㅇㄹ</h2>
<hr>
<p>ㅁㄴㅇㄹ</p>
<a href="/">목록</a>
<a href="/board/2/edit">수정</a>
<a rel="nofollow" data-method="delete" href="/board/2">삭제</a>
...
```

- `data-method="delete"`로 코드가 생성된 것을 확인할 수 있다. 여기에 속성을 추가하여 지난번 처럼 `confirm` 메시지를 띄울 수도 있다.



### Login

- session과 cookie의 가장 큰 차이는 저장되는 위치이다. cookie는 사용자의 브라우저에 저장된다. session은 서버에 저장되고 session-id를 브라우저(클라이언트)에 저장한다. 사용자가 접속할 때마다 독립적인 session이 만들어지고 해당 session에 여러 정보를 저장하여 사용할 수 있다. 해당 정보는 DB와는 달리 휘발성이다.
- 우리가 로그인한 정보는 이 session에 저장된다. session에 개발자가 정해둔 key에 사용자 정보를 저장하면 원할때 꺼내서 사용할 수 있다. session에 새로운 key와 value를 저장하는 방법은 해쉬를 사용하는 방식과 유사하다. `session[:user_id] = user.id`의 방식으로 저장할 수 있다.

*config/routes.rb*

```ruby
...
	get '/sign_in' => 'user#sign_in'
    post '/sign_in' => 'user#user_sign_in'
...
```

*app/controllers/user_controller.rb*

```ruby
...
  def sign_in
  end
  
  def login
    # 유저가 입력한 ID, PW를 바탕으로
    # 실제로 로그인이 이루어지는 곳
    id = params[:user_id]
    pw = params[:password]
    user = User.find_by_user_id(id)
    if !user.nil? and user.password.eql?(pw)
      # 해당 user_id로 가입한 유저가 있고, 패스워드도 일치하는 경우
      session[:current_user] = user.id
      flash[:success] = "로그인에 성공했습니다."
      redirect_to '/users'
    else
      # 가입한 user_id가 없거나, 패스워드가 틀린경우
      flash[:error] = "가입된 유저가 아니거나, 비밀번호가 틀립니다."
      redirect_to '/sign_in'
    end
  end
...
```

- 사용자가 가입시 입력한 사용자의 id로 (DB table의 id 아님) 테이블에서 검색하여 비밀번호가 맞는지 확인하고 모두 맞다면 session에 유저의 정보(DB table의 id)를 담는다. 이때 입력한 session의 key는 반드시 기억해야 한다.
- 기타 정보가 아닌 id를 담는 이유는 해당 컬럼은 기본적으로 인덱싱이 완료되어 있고 타 값 검증 없이 유일값이라는 것이 보장되기 때문이다.

*app/views/user/sign_in.html.erb*

```erb
<h1>로그인</h1>
<%= form_tag do %>
    <%= text_field_tag(:user_id) %>
    <%= password_field_tag(:password) %>
    <%= submit_tag("로그인") %>
<% end %>
```

- 로그인 하는 페이지는 다음과 같이 구성된다.



### Logout

- 로그인 된 상태와 로그인되지 않은 상태는 무엇으로 구분할까. 두 상태의 차이는 session에 우리가 설정한 유저에 대한 키와 값의 존재 여부이다. 우리가 `current_user`로 설정한 값이 존재 한다면 로그인 된 상태이고 반대로 존재하지 않는다면 로그인되지 않은 상태이다.
- 로그인 된 상태에서 로그인 되지 않은 상태로 만드는 것이 로그아웃이다. 로그인 된 상태에서 로그아웃 상태로 바꾸려면 session에 등록된 `current_user` 정보를 삭제하면 된다. 이를 위해 구현되어 있는 메소드가 `session.delete(:key)`이다.

*app/controllers/user_controller.rb*

```ruby
...
  def logout
    session.delete(:current_user)
    flash[:success] = "로그아웃에 성공했습니다."
    redirect_to '/users'
  end
...
```

- 세션에 있는 키를 삭제하면 로그아웃시킬 수 있다.
- 추가적으로 로그인 된 상태에서는 로그아웃 버튼을, 로그아웃된 상태에서는 로그인 버튼을 보여주기 위한 코드는 다음과 같다.

*app/views/user/index.html.erb*

```erb
<% if @current_user.nil? %>
    <!-- 로그인 되지 않은 상태 -->
    <%= link_to '로그인', '/sign_in' %>
<% else %>
    <!-- 로그인 된 상태 -->
    <p>현재 로그인된 유저: <%= @current_user.user_id %></p>
    <%= link_to '로그아웃', '/logout' %>
<% end %>
...
```

*app/controllers/user_controller.rb*

```ruby
...  
  def index
    @users = User.all
    @current_user = User.find(session[:current_user]) if session[:current_user]
  end
...
```

- `@current_user` 변수에 세션에 저장되어있는 table id 값으로 검색하여 유저 정보를 저장한다. 위와 같은 방식으로 현재 접속한 유저 정보를 확인하고 사용할 수 있다.