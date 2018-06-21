# 20180621_Day10

### 검색

- 무언가 사용자 혹은 개발자가 원하는 데이터를 찾고자 할 때

- 검색방법

  - 일치
  - 포함
  - 범위
  - ...

- 우리가 그동안에 검색했던 방법은 **일치**. Table에 있는 id와 일치하는 것. 이 컬럼은 인덱싱이 되어 있기 때문에 검색 속도가 매우 빠르고 항상 고유한 값을 가진다.

  - Table에 있는 id로 검색을 할때에는 `Model.find(id)`를 사용한다.

- Table에 있는 id값으로 해결하지 못하는 경우?

  - 사용자가 입력했던 값으로 검색해야 하는 경우(`user_name`)
  - 게시글을 검색하는데, 작성자, 제목으로 검색할 경우
  - Table에 있는 다른 컬럼으로 검색할 경우에는 `Model.find_by_컬럼명(value)`, `Model.find_by(컬럼명: value)`
  - `find_by`의 특징: 1개만 검색됨, 일치하는 값이 없는 경우 `nil`

- 추가적인 검색방법: `Model.where(컬럼명: 검색어값)`

  - `User.where(user_name: "Hello")`
  - `where`의 특징: 검색결과가 여러개. 결과값이 배열 형태. 일치하는 값이 없는 경우에도 빈 배열이 나옴. 결과값이 비어있는 경우에`nil?`메소드의 결과값이 `false`로 나옴

- 포함?

  - 텍스트가 특정 단어/문장을 포함하고 있는가?

  - `Model.where("컬럼명 LIKE ?", "%#{value}%")`

  - `Model.where("컬렴명 LIKE '%#{value}%'")` 되기는 하지만 사용하면 안됨

  - 사용하면 안되는 이유는?

    - SQL Injection(해킹)이 발생할 수 있다.

    

### method & filter

- 액션에서는 반복되는 코드들이 매우 많다. 이러한 반복되는 코드들을 하나의 메소드로 만들고 액션에서 메소드를 호출해서 사용할 수 있다.

*app/controllers/board_controller.rb*

```ruby
...
  def set_post
    @post = Post.find(params[:id])
  end
...
```

- 메소드에서 저장한 인스턴스 변수는 액션에서도 활용할 수 있다. Request Cycle이 동작하는 동안 계속 유효하다.
- 하지만 단순히 메소드로 만들었다고 해서 메소드 호출까지 처리되는 것은 아니다. 액션이 실행되기 전에 반복되는 코드들을 미리 실행하는 filter를 활용하여 액션 실행을 처리할 수 있다.

*app/controllers/board_controller.rb*

```ruby
class BoardController < ApplicationController
    before_action :set_post, only: [:show, :edit, :update, :destroy]
...        
```

- 옵션으로`only`와 `except`를 줄 수 잇는데 `only` 옵션은 나열한 액션이 실행될 때만 필터가 동작하고, `except` 옵션은 나열한 액션을 제외한 액션이 실행될 때 필터가 동작한다.



- [filter 문서](http://guides.rubyonrails.org/action_controller_overview.html)를 보다보면 모든 컨트롤러는 `ApplicationController`를 상속받고 있으며, `ApplicationController`에서 선언한 메소드는 모든 컨트롤러에서 메소드로 쓸 수 있다고 적혀있다.
- 이를 활용하여 로그인과 관련된 일부 메소드를 구현해보자.

> 이는 Devise 잼을 활용할 때 낯설지 않게 하기 위해서, 그리고 그 코드가 어떻게 동작하는 지 알기 위해서 진행했다.

*app/controllers/application_controller.rb*

```ruby
class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  
  # 현재 로그인 된 상태를 확인
  # 로그인 한 경우 true, 아닌 경우 false
  def user_signed_in?
    session[:current_user].present?
  end
  
  # 로그인 되어 있지 않을 경우 로그인 된 페이지로 이동
  def authenticate_user!
    unless user_signed_in?
      redirect_to '/sign_in'
    end
  end  
  
  # 현재 로그인 된 사람의 정보를 return
  # 비어있는 경우 nil 이 return 됨
  def current_user
    # 현재 로그인됐다면
    # 됐다면 로그인 한 사람은 누구니?
     @current_user = User.find(session[:current_user]) if user_signed_in?  
  end
end
```

- `user_signed_in?` : 메소드에 `?`가 붙는다면 리턴값이 `true`/ `false`임을 의미한다. 조건문의 조건으로 사용할 수 있다. 로그인 된 유저가 있는지 확인하는 메소드이다.
- `authenticate_user!` : 메소드에 `!`이 붙어 있으면 사용자의 요청과 맞지 않는 결과를 얻을 수 얻을 수 있다는 것을 의미한다. 해당 메소드는 로그인되지 않은 유저가 특정 페이지에 접근을 시도할 경우 로그인 페이지로 강제로 이동시키는 역할을 한다.
- `current_user` : 리턴값이 `nil`이거나 현재 로그인한 유저의 정보를 담는다. 후에 파이프(`||=`)를 이용하여 메소드를 보강해 나간다.

*app/controllers/board_controller.rb*

```ruby
...
    before_action :authenticate_user!, except: [:index, :show]
...
```

- 메소드를 작성하면 다른 컨트롤러에서도 사용할 수 있다. 특히 `authenticate_user!` 메소드의 경우 인증받지 못한 유저가 접근할 경우 로그인 페이지로 리디렉션 시키는 역할을 하기 때문에 필터로 활용하면 좋다.

- 나머지 두개의 메소드는 view에서 로직을 처리할 때 많이 사용되는데 기본적으로 컨트롤러에 있는 메소드는 view에서 호출할 수 없다. 하지만 좋은 메서드를 만들었으면 잘 활용해야 하는 법! view에서도 컨트롤러의 메소드를 활용하기 위해서 `helper method`를 지정한다.

*app/controllers/application_controller.rb*

```ruby
...
	helper_method :user_signed_in?, :current_user
...
```

- 이렇게 지정하면 어떠한 뷰에서도 해당 메소드를 활용할 수 있다. 다만 `current_user`는 현재 로그인 된 유저가 없을 경우 `nil`을 리턴하니 반드시 `user_signed_in?`과 함께 사용하는 방식으로 사용한다.



## Association/Relation

- 레일즈를 사용하는 큰 이유중 하나는 ORM(Object Reloadtionship Mapper)을 매우 편하게 사용할 수 있다는 점이다. 기존의 다른 프레임워크(Spring 등)를 사용해본 사람이라면 더욱 쉽게 느낄 것이다.
- 한명의 유저는 여러개의 글을 작성할 수 있고, 하나의 글은 작성자 한명을 가질 수 있다. 이러한 관계를 **1:N**관계라 한다. 
- 1:N 관계를 구현하기 위해서 먼저 N쪽이 되는 모델의 마이그레이션에 컬럼을 추가한다.

*db/migrate/create_posts.rb*

```ruby
class CreatePosts < ActiveRecord::Migration[5.0]
  def change
    create_table :posts do |t|
      t.string :title
      t.text   :contents
      t.integer :user_id
      t.timestamps
    end
  end
end
```

- 컬럼명은 `1이 되는 쪽의 모델명_id` 이다. `user`와 `post` 모델의 관계를 설정할 때 `post` 모델이 N쪽이 되기 때문에 `create_posts.rb`파일에 컬럼을 추가한다.

```command
$ rake db:drop db:migrate
```

- 축약된 명령어로 drop과 migrate를 한번에 진행할 수 있다.

*app/models/user.rb*

```ruby
...
    has_many :posts
...
```

*app/models/post.rb*

```ruby
...
    belongs_to :user
...
```

- 각각의 모델에 코드를 한 줄씩 추가하면 두 모델 간의 **1:N** 관계가 완성된다.

```irb
> u = User.new
> u.user_name = "haha"
> u.password = "1234"
> u.save
> p = Post.new
> p.title = "Test Title"
> p.contents = "Test Contents"
> p.user_id = u.id
> p.save
> p.user
> u.posts
```

- 위와같은 방식으로 사용할 수 있다. 유저 쪽에서는 해당 유저가 작성한 모든 글을 출력할 수 있다.

*app/controllers/board_controller.rb*

```ruby
...
  def create
    post = Post.new
    post.title = params[:title]
    post.contents = params[:contents]
    post.user_id = current_user.id
    post.save
    # post를 등록할 때 이 글을 작성한 사람은
    # 현재 로그인 되어 있는 유저이다.
    flash[:success] = "새 글이 등록되었습니다."
    redirect_to "/board/#{post.id}"
  end
...
```

- 글을 등록할 때 `user_id` 컬럼에 현재 로그인 된 유저의 id를 넣어주면 위 irb에서 진행했던 내용과 동일하게 관계를 설정할 수 있다.

*app/views/user/show.html.erb*

```erb
<p>이 유저가 작성한 글</p>
<% @user.posts.each do |post| %>
    <%= link_to post.title, "/board/#{post.id}" %><br>
<% end %>
```

- 유저가 작성한 글을 위와같이 확인할 수 있다.

*app/views/board/show.html.erb*

```erb
<p>작성자: <%= @post.user.user_name %></p>
```

- 글을 작성한 유저를 확인할 수 있다.