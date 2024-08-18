'use client'
import axios, { AxiosResponse } from "axios";
import {useEffect, useState} from 'react'
import { useRouter } from 'next/navigation'
import { createConsumer } from "@rails/actioncable"

const axiosURL = process.env.NEXT_PUBLIC_BASE_URL || "http://localhost:3000";
const actionCableURL = process.env.NEXT_PUBLIC_BASE_ACTIONCABLE_URL || "ws://localhost:3000/cable";
const baseAxios = axios.create({
  baseURL: axiosURL,
  headers: {
    "Content-type": "application/json",
  },
  withCredentials: true // 追加
});

export default function Match() {

  const [requestFlg, setRequestFlg] = useState(false);
  const [waitingFlg, setWaitingFlg] = useState(false);
  const [opponent, setOpponent] = useState({id: 0, name: ""});
  const [matchList, setMatchList] = useState([{id: 0, name: ""}]);
  const router = useRouter();
  const consumer = createConsumer(actionCableURL);
  
  function setData(res: AxiosResponse<any, any>){
    if(res.data.errMsg){
      console.log(res.data.errMsg);
      return;
    }
    console.log(res.data);
    setOpponent(res.data.opp);
    setRequestFlg(res.data.requestFlg);
    setWaitingFlg(res.data.waitingFlg);
    setMatchList(res.data.userList);
  }

  async function enterRoom(){
    await baseAxios.post('enterRoom')
    .then((res) => {
      setData(res);
      if(res.data.playingFlg){
        router.push(res.data.gameURL);
      }
    })
    .catch(error => {
      console.log("error: ", error);
    });
  }

  async function leaveRoom(){
    await baseAxios.delete('leaveRoom')
    .then((res) => {
      setData(res);
      router.push('/');
    })
    .catch(error => {
      console.log("error: ", error);
    });
  }

  async function getRoomInfo(){
    await baseAxios.get('getRoomInfo')
    .then((res) => {
      setData(res);
    })
    .catch(error => {
      console.log("error: ", error);
    });
  }

  async function makeRequest(opp_id: number){
    await baseAxios.patch('makeRequest', {
      opp_id: opp_id,
    })
    .then((res) => {
      setData(res);
    })
    .catch(error => {
      console.log("error: ", error);
    });
  }

  async function acceptRequest(opp_id: number){
    await baseAxios.patch('acceptRequest', {
      opp_id: opp_id,
    })
    .then((res) => {
      setData(res);
    })
    .catch(error => {
      console.log("error: ", error);
    });
  }

  async function declineRequest(opp_id: number){
    await baseAxios.patch('declineRequest', {
      opp_id: opp_id,
    })
    .then((res) => {
      setData(res);
    })
    .catch(error => {
      console.log("error: ", error);
    });
  }
  
  useEffect(() => {
    enterRoom();

    const appMatch = consumer.subscriptions.create("MatchChannel", {
      connected() {
        // Called when the subscription is ready for use on the server
        console.log("connected")
      },
    
      disconnected() {
        // Called when the subscription has been terminated by the server
      },
    
      received(data) {
        // Called when there's incoming data on the websocket for this channel
        console.log("_____receive data________");

        if(true == data.data["reload"]){
          router.push(data.data.gameURL);
        }
        else{
          getRoomInfo();
        }        
      },
    });
  }, []);

  return (
    <div>
      <div>
        <h1>対局室</h1>
        <h2>対戦待ちユーザー</h2>
        <ul>
          {
            requestFlg ? (
              <li>
                <p className="user_list">{opponent ? opponent.name: null} へ対戦を申し込んでいます。</p>
                <button 
                  className="btn btn-outline-primary"
                  onClick={() => declineRequest(opponent.id)}> 取り消し</button>
              </li>
            ) : (<></>)
          }
          {
            waitingFlg ? (
              <li>
                <p className="user_list">{opponent ? opponent.name: null} から対戦を申し込まれています。</p>
                <button 
                  className="btn btn-outline-primary m-1"
                  onClick={() => acceptRequest(opponent.id)}> 承諾</button>
                <button 
                  className="btn btn-outline-primary m-1"
                  onClick={() => declineRequest(opponent.id)}> 拒否</button>
              </li>
            ) : (<></>)
          }
          {
            matchList.map((match, i) => {
              return(
                <li key={match.id}>
                  <p className="user_list">{match.name}</p>
                  <button 
                    className="btn btn-outline-primary m-1" 
                    onClick={() => makeRequest(match.id)}>対戦
                  </button>
                </li>
              )
            })
          }
        </ul>

        <div>
          <button className="btn btn-primary" onClick={() => leaveRoom()}>退出する</button>
        </div>

      </div>
    </div>
  );
}
