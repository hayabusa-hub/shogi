'use client'
import axios, { AxiosResponse } from "axios";
import {useEffect, useState} from 'react'
import { useRouter } from 'next/navigation'
import { createConsumer } from "@rails/actioncable"
import Image from "next/image";

const axiosURL = process.env.NEXT_PUBLIC_BASE_URL || "http://localhost:3000";
const actionCableURL = process.env.NEXT_PUBLIC_BASE_ACTIONCABLE_URL || "ws://localhost:3000/cable";
const baseAxios = axios.create({
  baseURL: axiosURL,
  headers: {
    "Content-type": "application/json",
  },
  withCredentials: true // 追加
});

export default function Game({ params }: { params: { gameId: string } }) {

  const [rowHeader, setRowHeader] = useState([]);
  const [colHeader, setColHeader] = useState([]);
  const [gameBoard, setGameBoard] = useState("");
  const [turnBoard, setTurnBoard] = useState("");
  const [order, setOrder] = useState([]);
  const [display, setDisplay] = useState(0);
  const [myTurn, setMyTurn] = useState(0);
  const [frontUserName, setFrontUserName] = useState("");
  const [backUserName, setBackUserName] = useState("");
  const [frontOwnPieceList, setFrontOwnPieceList] = useState([]);
  const [backOwnPieceList, setBackOwnPieceList] = useState([]);
  const [beforePos, setBeforePos] = useState(-1);
  const [afterPos, setAfterPos] = useState(-1);
  const [latestPos, setLatestPos] = useState(-1);
  const [orgPiece, setOrgPiece] = useState("");
  const [proPiece, setProPiece] = useState("");
  const [confirmFlg, setConfirmFlg] = useState(null);
  const [winner, setWinner] = useState(0);

  const router = useRouter();
  const consumer = createConsumer(actionCableURL);
  
  function setAllData(res: AxiosResponse<any, any>){
    if(res.data.errMsg){
      console.log(res.data.errMsg);
      return;
    }
    // console.log(res.data);
    setRowHeader(res.data.row);
    setColHeader(res.data.col);
    setMyTurn(res.data.myTurn);
    setOrder(res.data.order);
    setDisplay(res.data.display);
    setFrontUserName(res.data.frontUserName);
    setBackUserName(res.data.backUserName);

    setGameData(res);
  }

  function setGameData(res: AxiosResponse<any, any>){
    if(res.data.errMsg){
      console.log(res.data.errMsg);
      return;
    }
    // console.log(res.data);
    
    setGameBoard(res.data.board);
    setTurnBoard(res.data.turnBoard);
    setLatestPos(res.data.latestPos);
    setConfirmFlg(res.data.confirmFlg);
    setFrontOwnPieceList(res.data.frontOwnPieceList);
    setBackOwnPieceList(res.data.backOwnPieceList);
    setWinner(res.data.winner);
  }

  async function getGameData(){
    await baseAxios.get(`/games/${params.gameId}`)
    .then((res) => {
      setAllData(res);
    })
    .catch(error => {
      console.log("error: ", error);
    });
  }

  function get_image_path(piece: string, turn: number, display: number){
    let image_path = ""

    if (null != piece){
      image_path = "/shogi/"
      if ((turn != display) && (turn != 0)){
        image_path += "opp_";
      }
      image_path += piece + ".png"
    }
    
    return image_path
  }

  function putPiece(pos: number, turn: number, promoteFlg: boolean, selectFlg: boolean){
    console.log("put piece");
    console.log(`myTurn: ${myTurn}, turn: ${turn}`);
    if(myTurn == turn){
      setBeforePos(pos);
    }
    else if(beforePos != -1){
      
      baseAxios.patch(`/games/${params.gameId}/updateBoard`, {
        before_pos: beforePos,
        after_pos: pos,
        promote_flg: promoteFlg,
        select_flg: selectFlg,
      })
      .then((res) => {
        setGameData(res);
        if(res.data.confirmFlg){
          console.log("成駒選択");
          setAfterPos(pos);
          setOrgPiece(res.data.orgPiece);
          setProPiece(res.data.proPiece);
        }
        else{
          console.log("着手");
          setBeforePos(-1);
          setAfterPos(-1);
        }
      })
      .catch(error => {
        console.log("error: ", error);
      });
    }
  }

  const makeSettle = () => {
    let image_path = "";
    if(winner == myTurn){
      image_path = "/shogi/pose_win.png";
    }
    else if(winner == (myTurn^3)){
      image_path = "/shogi/pose_lose.png";
    }
    else{
      image_path = "/shogi/pose_draw.png";
    }

    return (
      <div id="finish" className="backFull">
        <div className="center">
          <button className="" onClick={() => {
            baseAxios.delete('leaveRoom')
            .then((res) => {
              router.push('/');
            })
            .catch(error => {
              console.log("error: ", error);
            });
          }}>
            <Image 
              src={image_path} 
              alt=""
              width="300"
              height="300"
            />
          </button>
        </div>
      </div>
    )
  }

  const makeConfirmPromote = (promote_flg: boolean) => {
    const id_name = promote_flg ? "promote" : "notPromote";
    const piece = promote_flg ? proPiece : orgPiece;

    return (
      <li id={id_name} className="inlineBlock">
        <button onClick={() => putPiece(afterPos, 0, promote_flg, true)}>
          <Image 
            src={get_image_path(piece, myTurn, display)} 
            alt=""
            width="50"
            height="50"
            className="board_cell"
          />
        </button>
      </li>
    )
  }

  const makeUserInfo = (turn: number) => {
    const className = (display == turn) ? "frontDisplayUser": "backDisplayUser";
    const userName = (display == turn) ? frontUserName: backUserName;
    return (
      <tbody className={className}>
        <tr>
          <td className="border-none user_name">
            {userName}
          </td>
        </tr>
        <tr>
          <td className="border-none time">残り時間：∞
          </td>
        </tr>
      </tbody>
    );
  }

  const makeOwnPieceBoard = (turn: number) => {
    let board = [];
    const idName = (display == turn) ? "front": "back";
    const ownPieceList = (display == turn) ? frontOwnPieceList: backOwnPieceList;

    for(let piece = 1; piece <= 8; piece++){
      const num = ownPieceList[piece];
      const pos = turn * 100 + piece;
      if(num >= 1){
        board.push(
          <tr key={piece}>
            <td>
              <button onClick={() => putPiece(pos, turn, false, false)}>
                <Image 
                  src={get_image_path(String(piece), turn, display)} 
                  alt=""
                  width="50"
                  height="50"
                  className={"image" + (pos == beforePos ? " board_primary" : "")}
                />
              </button>
            </td>
            { 
              (num >= 2) ? (
                <td className="border-none">
                   × {num}
                </td>
              ) : <></>
            }
          </tr>
        )
      }
    }
    return (
      <tbody id={idName}>{board}</tbody>
    );
  }

  const makeGameBoard = () => {
    let board = [];
    for(let row of order){
      let rowBoard = [];
      for(let col of order){
        const pos = row * 9 + col;
        const piece = gameBoard[pos];
        const turn =  Number(turnBoard[pos]);
        rowBoard.push(
          <td key={pos} className="board_cell border_line">
            <button onClick={() => putPiece(pos, turn, false, false)}>
            {
              piece != "0" ? (
                <Image 
                  src={get_image_path(piece, turn, display)} 
                  alt=""
                  width="50"
                  height="50"
                  className={
                    "board_cell" + 
                    (pos == beforePos ? " board_primary" :"") +
                    (pos == latestPos ? " latest_place" : "")
                  }
                />
              ): <div className="empty_cell"></div>
            }
            </button>
            
          </td>
        )
      }
      board.push(
        <tr key={"row"+ row} className="border_line">
          {rowBoard}
          <td>
            {rowHeader[row]}
          </td>
        </tr>
      )
    }
    return (
      <table className="displayBoard">
        <tbody className="board_table">
          <tr>
            {
              order.map((col, i) => {
                return (
                    <td key={"col"+col} className="textCenter">{colHeader[col]}</td>
                );
              })
            }
          </tr>
          {board}
        </tbody>

        {/* 手前側の持ち駒 */}
        {makeOwnPieceBoard(display)}

        {/* 奥側の持ち駒 */}
        {makeOwnPieceBoard(display^3)}

        {/* 手前側のユーザー情報 */}
        {makeUserInfo(display)}

        {/* 奥側のユーザー情報 */}
        {makeUserInfo(display^3)}
      </table>
    );
  }
  
  useEffect(() => {
    getGameData();

    const appMatch = consumer.subscriptions.create("GameChannel", {
      connected() {
        // Called when the subscription is ready for use on the server
        console.log("game channel is connected")
      },
    
      disconnected() {
        // Called when the subscription has been terminated by the server
      },
    
      received(data) {
        // Called when there's incoming data on the websocket for this channel
        console.log("receive game data");
        console.log(data);
        getGameData();      
      },
    });
  }, []);

  return (
    <div>
      <h1>対局</h1>
      <div className="displayField">
        {makeGameBoard()}
      </div>

      {
        confirmFlg ? (
          <div id="confirmPromote" className="backFull">
            <ul className="center_ul">
              {makeConfirmPromote(false)}
              {makeConfirmPromote(true)}
            </ul>
          </div>
        ) : (<></>)
      }

      {
        (0 != winner) ? (
          makeSettle()
        ): (<></>)
      }
    </div>
  );
}
