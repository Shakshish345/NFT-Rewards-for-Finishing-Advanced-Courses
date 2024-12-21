// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract LearnToEarnStreaming {
    struct Course {
        uint256 id;
        string name;
        string description;
        uint256 reward;
        address creator;
    }

    struct User {
        uint256 totalEarnings;
        mapping(uint256 => bool) completedCourses;
    }

    uint256 public nextCourseId;
    address public owner;
    mapping(uint256 => Course) public courses;
    mapping(address => User) public users;

    event CourseCreated(uint256 id, string name, uint256 reward, address indexed creator);
    event CourseCompleted(address indexed user, uint256 courseId, uint256 reward);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can perform this action");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function createCourse(string memory _name, string memory _description, uint256 _reward) public onlyOwner {
        require(_reward > 0, "Reward must be greater than zero");

        courses[nextCourseId] = Course({
            id: nextCourseId,
            name: _name,
            description: _description,
            reward: _reward,
            creator: msg.sender
        });

        emit CourseCreated(nextCourseId, _name, _reward, msg.sender);
        nextCourseId++;
    }

    function completeCourse(uint256 _courseId) public {
        Course storage course = courses[_courseId];
        User storage user = users[msg.sender];

        require(bytes(course.name).length > 0, "Course does not exist");
        require(!user.completedCourses[_courseId], "Course already completed");

        user.completedCourses[_courseId] = true;
        user.totalEarnings += course.reward;

        payable(msg.sender).transfer(course.reward);
        emit CourseCompleted(msg.sender, _courseId, course.reward);
    }

    function depositRewards() public payable onlyOwner {
        require(msg.value > 0, "Deposit amount must be greater than zero");
    }

    function withdrawFunds(uint256 _amount) public onlyOwner {
        require(address(this).balance >= _amount, "Insufficient contract balance");
        payable(owner).transfer(_amount);
    }

    function getTotalEarnings(address _user) public view returns (uint256) {
        return users[_user].totalEarnings;
    }

    function getContractBalance() public view returns (uint256) {
        return address(this).balance;
    }
}
