// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

contract Auction {
    
        //the one who will conduct aution
        address payable  public autionneer;

        //start time
        uint public startTimeBlock;

        //End time
        uint public EndTimeBlock;

        //to define state of contarct
        enum Auction_State {
            Started,
            Running,
            End,
            Cancelled
        }
    
        Auction_State  public auctionState;

        uint public  highest_payble_bid;
        uint public  bid_inc;


        address payable public highestBidder;

        mapping(address => uint) public  bids;

        constructor() 
        {
            autionneer =payable (msg.sender);
            auctionState=Auction_State.Running;
            startTimeBlock=block.number;
            EndTimeBlock=startTimeBlock+1;
            bid_inc=1 ether;
        }


        modifier notOwner(){
            require(msg.sender!=autionneer,"Owener can not bid");
            _;
        }

        modifier Owner(){
            require(msg.sender==autionneer,"Owener can not bid");
            _;
        }

        modifier started(){
            require(block.number >startTimeBlock,"");
            _;
        }

        modifier  Beforended(){
            require(block.number > EndTimeBlock,"");
            _;
        }

        function cancelAution()  public Owner {
            auctionState=Auction_State.Cancelled;

        }

         function ENDAution()  public Owner {
            auctionState=Auction_State.End;

        }

        function min(uint a,uint b) private  pure returns (uint){
            if(a <=b){
                return  a;
            }else{
                return  b;
            }
        }

        function bid() payable public notOwner started Beforended {

            require(auctionState==Auction_State.Running);

            require(msg.value >= 1);

            uint currentBid = bids[msg.sender] + msg.value;

            require(currentBid > highest_payble_bid);

            bids[msg.sender]=currentBid;

            if(currentBid < bids[highestBidder]){
                highest_payble_bid=min(currentBid+bid_inc,bids[highestBidder]);
            }else{
                highest_payble_bid=min(currentBid+bid_inc,bids[highestBidder]+bid_inc);
                highestBidder=payable(msg.sender);
            }
            
        }



        function finallizeAuction()  public Owner  {
            require(auctionState==Auction_State.Cancelled ||auctionState==Auction_State.End || block.number >EndTimeBlock,"Auction Close");
            require(msg.sender==autionneer || bids[msg.sender] >0);

            address payable receiveBidders;
            uint bidAmount;


            if(auctionState==Auction_State.Cancelled){
                receiveBidders =payable (msg.sender);
                bidAmount=bids[msg.sender];

            }else{

                if(msg.sender == autionneer){

                    receiveBidders=autionneer;
                    bidAmount=highest_payble_bid;

                }else{
                    if(msg.sender == highestBidder){
                        receiveBidders=highestBidder;
                        bidAmount=bids[highestBidder]-highest_payble_bid;
                    }else{
                        receiveBidders=payable (msg.sender);
                        bidAmount=bids[msg.sender];

                    }
                }

            }  
                bids[msg.sender]=0;
                receiveBidders.transfer(bidAmount);

        }


        




}
