'use client'
import Link from 'next/link'
import axios, { AxiosResponse } from "axios";
import {useEffect, useState} from 'react'

const baseAxios = axios.create({
  baseURL: process.env.NEXT_PUBLIC_BASE_URL || "http://localhost:3000",
  headers: {
    "Content-type": "application/json",
  },
  withCredentials: true // 追加
})

// axios.defaults.baseURL =
//   process.env.NEXT_PUBLIC_BASE_URL || "http://localhost:3000";

export default function Home() {

  const [id, setId] = useState();
  const [name, setName] = useState("");
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [loginStatus, setLoginStatus] = useState(false);

  async function login(){
    await baseAxios.post('login', {
      email: email,
      password: password,
    })
    .then((res) => {
      setData(res);
    })
    .catch(error => {
      console.log("error: ", error);
    });
  }

  async function logout(){
    await baseAxios.delete('logout')
    .then((res) => {
      setData(res);
    })
    .catch(error => {
      console.log("error: ", error);
    });
  }

  async function isLogin(){
    await baseAxios.get('isLogin?')
    .then((res) => {
      setData(res);
    })
    .catch(error => {
      console.log("error: ", error);
    });
  }

  function setData(res: AxiosResponse<any, any>){
    setLoginStatus(res.data.isLogin);
    setId(res.data.userId);
    setName(res.data.userName);
  }

  function guestLogin(id: number){
    setEmail(`user${id}@example.com`);
    setPassword("aaaaaa");
  }
  
  useEffect(() => {
    isLogin();
  }, [])

  return (
    <div>
      {
        loginStatus ? (
          <div>
            <h1>将棋対戦</h1>
            <div>
              <Link href="/">対局室へ移動</Link>
            </div>
            <div>
              <Link href="/">観戦</Link>
            </div>
            <div>
              <Link href="/">マイページ</Link>
            </div>

            <button onClick={() => logout()}>
              ログアウト
            </button>
          </div>
        ) : (
          <div>
            <h1>ログイン</h1>
            <div className="row">
              <div className="col-md-6 col-md-offset-3">
                <div>
                  
                  <label>メールアドレス</label>
                  <input className="form-control" type="email" value={email} 
                        onChange={(e) => setEmail(e.target.value)} />
                  
                  <label>パスワード</label>
                  <input className="form-control" type="password" value={password}
                        onChange={(e) => setPassword(e.target.value)} />
                
                  <button name="commit" className="btn btn-primary" onClick={() => login()}>
                    ログイン
                  </button>
                </div>
              </div>
            </div>
          </div>
        )
      }
      

      <div>
        {/* {user.user.id} */}
        {id}, {name}
        {/* , {email}, {password} */}
      </div>
      <div>
        isLogin?: {loginStatus ? "true": "false"}
        
      </div>
      <div>
        isLogin?: {loginStatus}
      </div>

      <button onClick={() => {
        isLogin();
      }}>
        確認
      </button>

      <div onClick={() => guestLogin(1)}>user1</div>
      <div onClick={() => guestLogin(2)}>user2</div>
      <div onClick={() => guestLogin(3)}>user3</div>
      <div onClick={() => guestLogin(4)}>user4</div>
      <div onClick={() => guestLogin(5)}>user5</div>
    </div>
  );
}
