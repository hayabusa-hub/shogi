'use client'
import Link from 'next/link'
import axios, { AxiosResponse } from "axios";
import {useEffect, useState} from 'react'
import { useRouter } from 'next/navigation'

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
  const router = useRouter();

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

  async function enterRoom(){
    router.push("/match");
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
            <div className="container">
              <div className="row">
                
                <div>
                  <h3>
                    ようこそ {name} さん
                  </h3>

                  <div className="offset-md-4">
                    <button 
                      name="commit" 
                      className="btn btn-primary m-1 btn-block col-md-6 " 
                      onClick={() => {
                        enterRoom();
                      }}>
                        対局室へ移動
                    </button>      
                  </div>

                  <div className="offset-md-4">
                    <button 
                      name="commit" 
                      className="btn btn-primary m-1 btn-block col-md-6" 
                      disabled>
                        観戦
                    </button>
                  </div>

                  <div className="offset-md-4">
                    <button 
                      name="commit" 
                      className="btn btn-primary m-1 btn-block col-md-6" 
                      disabled>
                        マイページ
                    </button>
                  </div>

                  <div className="offset-md-7">
                    <button 
                      name="commit" 
                      className="btn btn-link m-1 col-md-3" 
                      onClick={() => logout()}>
                        ログアウト
                    </button>
                  </div>

                </div>
              </div>
            </div>

          </div>
        ) : (
          <div>
            <h1>ログイン</h1>
            <div className="container">
              <div className="row">
                <div className="col-md-6 offset-md-3">
                  <div>
                    
                    <label>メールアドレス</label>
                    <input className="form-control m-1" type="email" value={email} 
                          onChange={(e) => setEmail(e.target.value)} />
                    
                    <label>パスワード</label>
                    <input className="form-control m-1" type="password" value={password}
                          onChange={(e) => setPassword(e.target.value)} />
                  
                    <button name="commit" className="btn btn-primary m-1" onClick={() => login()}>
                      ログイン
                    </button>
                  </div>
                </div>
              </div>

              <div className="guest">
                <label>ゲストログイン</label>
                {
                  (function () {
                    const list = [];
                    for(let i = 1; i <= 5; i++){
                      list.push(
                        <div>
                          <button 
                            className="btn m-1 btn-outline-dark" onClick={() => guestLogin(i)}>
                              user{i}
                          </button>
                        </div>
                      )
                    }
                    return list;
                  }())
                }
              </div>

            </div>
          </div>
        )
      }
      
    </div>
  );
}
