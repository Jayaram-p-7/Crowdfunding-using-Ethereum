// We will be using Solidity version 0.5.4
pragma solidity 0.5.4;
// Importing OpenZeppelin's SafeMath Implementation
import './SafeMath.sol';


contract Crowdfunding {
    using SafeMath for uint256;

    // List of existing projects
    Project[] private projects;

    // Event that will be emitted whenever a new project is started
    event ProjectStarted(
        address contractAddress,
        address projectStarter,
        string projectTitle,
        string projectDesc,
        uint256 deadline,
        uint256 goalAmount,
        bool reward,
        uint256 milestone
    );

    /** @dev Function to start a new project.
      * @param title Title of the project to be created
      * @param description Brief description about the project
      * @param durationInDays Project deadline in days
      * @param amountToRaise Project goal in wei
      */
    function startProject(
        string calldata title,
        string calldata  description,
        uint durationInDays,
        uint256 amountToRaise,
        bool reward,
        uint256 milestone
    ) external {
        uint raiseUntil = now.add(durationInDays.mul(1 days));
        Project newProject = new Project(msg.sender, title, description, raiseUntil, amountToRaise,reward,milestone);
        projects.push(newProject);
        emit ProjectStarted(
            address(newProject),
            msg.sender,
            title,
            description,
            raiseUntil,
            amountToRaise,
            reward,
            milestone
        );
    }                                                                                                                                   

    /** @dev Function to get all projects' contract addresses.
      * @return A list of all projects' contract addreses
      */
    function returnAllProjects() external view returns(Project[] memory){
        return projects;
    }
}


contract Project {
    using SafeMath for uint256;
    
    // Data structures
    enum State {
        Fundraising,
        Expired,
        Successful
    }

    // State variables
    address payable public creator;
    uint256 public orggoalammount;
    uint256 public amountGoal; // required to reach at least this much, else everyone gets refund
    uint public completeAt;
    uint256 public currentBalance;
    uint256 public donateBalance;
    uint public percent;
    uint public raiseBy;
    string public title;
    string public description;
    bool public rewardbased;
    bool public rewardstatus;
    State public state = State.Fundraising; // initialize on create
    address[] public contributors;
    mapping (address => uint) public indexes;
    mapping (address => uint) public contributions;
    mapping (address => uint) public contributions_percentage;
    uint256 public currentmilestone;
    bool public milestonestatus;
    uint[] public listofmilestones;

    // Event that will be emitted whenever funding will be received
    event FundingReceived(address contributor, uint amount, uint currentTotal);
    // Event that will be emitted whenever the project starter has received the funds
    event CreatorPaid(address recipient);

    // Modifier to check current state
    modifier inState(State _state) {
        require(state == _state);
        _;
    }

    // Modifier to check if the function caller is the project creator
    modifier isCreator() {
        require(msg.sender == creator);
        _;
    }

    constructor
    (
        address payable projectStarter,
        string memory projectTitle,
        string memory projectDesc,
        uint fundRaisingDeadline,
        uint256 goalAmount,
        bool reward,
        uint256 milestone
    ) public {
        creator = projectStarter;
        title = projectTitle;
        description = projectDesc;
        amountGoal = goalAmount;
        orggoalammount=goalAmount;
        raiseBy = fundRaisingDeadline;
        currentBalance = 0;
        rewardbased=reward;
        rewardstatus=false;
        currentmilestone=milestone;
        milestonestatus=true;
        listofmilestones.push(milestone);
    }
    
    /** @dev Function to fund a certain project. 
      */
    function contribute() external inState(State.Fundraising) payable {
        require(msg.sender != creator);
        contributions[msg.sender] = contributions[msg.sender].add(msg.value);
        uint id =contributors.length+1;
        if(indexes[msg.sender]==0){
        indexes[msg.sender] = id;
        contributors.push(msg.sender);}
        // contribution percentages for reward based project
        if(rewardbased) {
        uint _numerator  = msg.value * 10 ** (4);
        percent =  ((_numerator / amountGoal)+5) / 10;
        contributions_percentage[msg.sender]=contributions_percentage[msg.sender].add(percent);
        }
        
        currentBalance = currentBalance.add(msg.value);
        emit FundingReceived(msg.sender, msg.value, currentBalance);
        checkIfFundingCompleteOrExpired();
    }
    
    function donate() external inState(State.Successful) payable {
        require(msg.sender == creator);
        donateBalance = donateBalance.add(msg.value);
        rewardstatus=true;
    }

    /** @dev Function to change the project state depending on conditions.
      */
    function checkIfFundingCompleteOrExpired() public {
        if (currentBalance >= currentmilestone && currentBalance<amountGoal) {
            payOut();
        } else if (currentBalance >= amountGoal)  {
            state = State.Successful;
            payOut1();
        } else if (currentBalance <= currentmilestone && now > raiseBy)  {
            state = State.Expired;
            if(!rewardbased) payOut2();
        }
        completeAt = now;
    }
    
    function updateMilestone(uint256 val,uint256 dat) external  {
        require(msg.sender == creator);
        currentmilestone = val;
        raiseBy = now.add(dat.mul(1 days)); 
        listofmilestones.push(currentmilestone);
        milestonestatus=true;
    }

    /** @dev Function to give the received funds to project starter.
      */
    function payOut() internal returns (bool) {
        uint256 totalRaised = currentBalance;
        currentBalance = currentBalance.sub(currentmilestone);

        if (creator.send(currentmilestone)) {
            amountGoal=amountGoal.sub(currentmilestone);
            currentmilestone=amountGoal;
            milestonestatus=false;
            emit CreatorPaid(creator);
            return true;
        } else {
            currentBalance = totalRaised;
        }

        return false;
    }
    
    function payOut1() internal returns (bool) {
        uint256 totalRaised = currentBalance;
        currentBalance=0;
        uint256 totalamount=amountGoal;
        amountGoal=0;
        milestonestatus=false;
        if (creator.send(totalRaised)) {
            emit CreatorPaid(creator);
            return true;
        } else {
            currentBalance = totalRaised;
            amountGoal=totalamount;
            state = State.Successful;
        }

        return false;
    }
    
    function payOut2() internal inState(State.Expired) returns (bool) {
        uint256 totalRaised = currentBalance;
        currentBalance = 0;
        uint256 totalamount=amountGoal;
        amountGoal=0;
        milestonestatus=false;
        if (creator.send(totalRaised)) {
            emit CreatorPaid(creator);
            return true;
        } else {
            currentBalance = totalRaised;
            amountGoal=totalamount;
            state = State.Expired;
        }

        return false;
    }
    
    /** @dev Function to retrieve donated amount when a project expires.
      */
    function getRefund() public inState(State.Expired) returns (bool) {
        require(contributions[msg.sender] > 0);
        
        uint amountToRefund = contributions[msg.sender];
        contributions[msg.sender] = 0;
        

        if (!msg.sender.send(amountToRefund)) {
            contributions[msg.sender] = amountToRefund;
            return false;
        } else {
            contributions_percentage[msg.sender]=0;
            currentBalance = currentBalance.sub(amountToRefund);
        }
        uint id = indexes[msg.sender];
        delete contributors[id-1];
        return true;
    }
   
    
     function getReward() public inState(State.Successful) returns (bool) {
        require(contributions_percentage[msg.sender] > 0);
        
        uint amountToRefund = contributions[msg.sender];
        uint amountPercent=contributions_percentage[msg.sender];
        uint money = (contributions_percentage[msg.sender]*donateBalance) /100;

        uint amountToReward = money/10;
        contributions[msg.sender] = 0;
        contributions_percentage[msg.sender]=0;

        if (!msg.sender.send(amountToReward)) {
            contributions[msg.sender] = amountToRefund;
            contributions_percentage[msg.sender] = amountPercent;
            return false;
        } else {
            donateBalance = donateBalance.sub(amountToReward);
        }
        uint id = indexes[msg.sender];
        delete contributors[id-1];

        return true;
    }

    /** @dev Function to get specific information about the project.
      * @return Returns all the project's details
      */
      
    function getMilestones() public view returns (uint[] memory arrmilestones) {
        return listofmilestones;
    }  
    
    function getDetails() public view returns 
    (
        address payable projectStarter,
        string memory projectTitle,
        string memory projectDesc,
        uint256 deadline,
        State currentState,
        uint256 currentAmount,
        uint256 goalAmount,
        bool reward,
        bool rewardstate,
        address[] memory contributers,
        uint256 milestonevalue,
        bool milestonestate
        
    ) {
        projectStarter = creator;
        projectTitle = title;
        projectDesc = description;
        deadline = raiseBy;
        currentState = state;
        currentAmount = currentBalance;
        goalAmount = orggoalammount;
        reward=rewardbased;
        rewardstate=rewardstatus;
        contributers=contributors;
        milestonevalue=currentmilestone;
        milestonestate=milestonestatus;
    }
}
