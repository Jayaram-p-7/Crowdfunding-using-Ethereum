<style scoped>
@import "./style.css";
</style>

<template>
  <v-app class="grey lighten-3">
    <v-content>
      <v-container>
        <v-layout text-xs-center wrap>
          <v-flex mb-4>
            <h1 class="display-2 font-weight-bold mb-3">Crowdfunding</h1>
            <p
              class="subheading font-weight-regular"
            >Utilizing Ethereum for Decentralized Crowdfunding</p>
          </v-flex>
        </v-layout>

        <v-layout row justify-center>
          <v-dialog v-model="startProjectDialog" max-width="600px" persistent>
            <v-btn slot="activator" color="primary" dark>Start a Project</v-btn>
            <v-card>
              <v-card-title>
                <span class="headline font-weight-bold mt-2 ml-4">Bring your project to life</span>
              </v-card-title>
              <v-card-text class="pt-0">
                <v-container class="pt-0" grid-list-md>
                  <v-layout wrap>
                    <v-flex xs12>
                      <v-text-field label="Title" persistent-hint v-model="newProject.title"></v-text-field>
                    </v-flex>
                    <v-flex xs12>
                      <v-textarea
                        label="Description"
                        persistent-hint
                        v-model="newProject.description"
                      ></v-textarea>
                    </v-flex>
                    <v-flex xs12>
                      <v-text-field
                        label="Amount Needed (ETH)"
                        type="number"
                        step="0.0001"
                        min="0"
                        v-model="newProject.amountGoal"
                      ></v-text-field>
                    </v-flex>
                    <v-flex xs12 sm6>
                      <v-text-field
                        label="Milestone Amount (ETH)"
                        type="number"
                        step="0.0001"
                        min="0"
                        v-model="newProject.milestone"
                      ></v-text-field>
                    </v-flex>
                    <v-flex xs12 sm6>
                      <v-text-field
                        label="Duration (in days) for Milestone"
                        type="number"
                        v-model="newProject.duration"
                      ></v-text-field>
                    </v-flex>
                    <v-flex>
                      <v-checkbox v-model="newProject.reward" color="success" label="Equity Based"></v-checkbox>
                    </v-flex>
                  </v-layout>
                </v-container>
              </v-card-text>
              <v-card-actions>
                <v-spacer></v-spacer>
                <v-btn
                  color="blue darken-1"
                  flat
                  @click="startProjectDialog = false;
                  newProject.isLoading = false;"
                >Close</v-btn>
                <v-btn
                  color="blue darken-1"
                  flat
                  @click="startProject"
                  :loading="newProject.isLoading"
                >Save</v-btn>
              </v-card-actions>
            </v-card>
          </v-dialog>
        </v-layout>
      </v-container>

      <v-container grid-list-lg>
        <div class="container" v-if="toggle_value==false">
          <v-btn
            color="primary"
            text-color="white"
            class="NonRewardBased"
            @click="toggle_value=false"
          >Other Projects</v-btn>
          <v-btn class="RewardBased" @click="toggle_value=true">My Projects</v-btn>
        </div>
        <div class="container" v-if="toggle_value==true">
          <v-btn
            class="NonRewardBased"
            @click="toggle_value=false"
          >Other Projects</v-btn>
          <v-btn color="primary"
            text-color="white"
            class="RewardBased" 
            @click="toggle_value=true">
            My Projects</v-btn>
        </div>
        <h1 class="display-1 font-weight-bold mb-3">Projects</h1>
        <v-layout row wrap>
          <v-flex v-for="(project, index) in projectData" :key="index" xs12>
            <v-dialog v-model="project.dialog" width="800">
              <v-card>
                <v-card-title class="headline font-weight-bold">{{ project.projectTitle }}</v-card-title>
                <v-card-text>
                  <b>Description :</b>
                  {{ project.projectDesc }}
                </v-card-text>
                <v-card-actions>
                  <v-spacer></v-spacer>
                  <v-btn
                    color="blue darken-1"
                    flat="flat"
                    @click="projectData[index].dialog = false"
                  >Close</v-btn>
                </v-card-actions>
              </v-card>
            </v-dialog>

            <v-hover>
              <v-card
                v-if="toggle_value ? account==project.projectStarter:account!=project.projectStarter "
                slot-scope="{ hover }"
                :class="`elevation-${hover ? 10 : 2}`"
              >
                <v-card-title primary-title>
                  <div style="width:100%">
                    <div class="headline font-weight-bold">
                      <v-chip
                        label
                        :color="stateMap[project.currentState].color"
                        text-color="white"
                        class="mt-0"
                      >{{ stateMap[project.currentState].text }}</v-chip>
                      {{ project.projectTitle }}
                      <v-dialog
                        class="MilestoneDialog"
                        v-model="project.startMilestoneDialog"
                        max-width="600px"
                        persistent
                      >
                        <v-btn slot="activator" color="primary" dark>
                          <v-icon>event_note</v-icon>
                        </v-btn>
                        <v-card>
                          <v-card-title class="headline font-weight-bold">List of Milestones</v-card-title>
                          <v-flex v-for="(val, ind) in projectMilestoneData[index]" :key="ind" xs12>
                            <v-flex style="margin-left:10%;">
                              <v-card-text
                                v-if="ind==projectMilestoneData[index].length-1 && project.milestonestate && project.currentState==0"
                              >
                                Milestone {{ind+1}} : {{val/ 10**18}} ETH
                                <v-icon style="margin-left:30%;color:orange" large>fast_forward</v-icon>
                              </v-card-text>
                              <v-card-text
                                v-else-if="ind==projectMilestoneData[index].length-1  && project.currentState==1"
                              >
                                Milestone {{ind+1}} : {{val/ 10**18}} ETH
                                <v-icon style="margin-left:30%;color:red" large>block</v-icon>
                              </v-card-text>
                              <v-card-text v-else>
                                Milestone {{ind+1}} : {{val/ 10**18}} ETH
                                <v-icon style="margin-left:30%;color:green" large>check_circle</v-icon>
                              </v-card-text>
                            </v-flex>
                          </v-flex>
                          <v-card-actions>
                            <v-spacer></v-spacer>
                            <v-btn
                              color="blue darken-1"
                              flat="flat"
                              @click="project.startMilestoneDialog = false"
                            >Close</v-btn>
                          </v-card-actions>
                        </v-card>
                      </v-dialog>
                      <v-btn
                        class="CheckProgress"
                        v-if="project.currentState==0 && account==project.projectStarter"
                        color="primary"
                        dark
                        @click="checkProgress(index)"
                        :loading="project.isLoading"
                      >Check Progress</v-btn>
                      <v-chip
                        v-if="project.reward"
                        color="success"
                        text-color="white"
                        class="RewardBasedIcon"
                      >
                        <v-avatar left>
                          <v-icon>info</v-icon>
                        </v-avatar>Equity Based
                      </v-chip>
                      <v-chip v-else color="success" text-color="white" class="RewardBasedIcon">
                        <v-avatar left>
                          <v-icon>info</v-icon>
                        </v-avatar>Donation Based
                      </v-chip>
                    </div>
                    <br />
                    <span>
                      <b>Description :</b>
                      {{ project.projectDesc.substring(0, 100) }}
                    </span>
                    <span v-if="project.projectDesc.length > 100">
                      ...
                      <a @click="projectData[index].dialog = true">[Show full]</a>
                    </span>
                    <br />
                    <br />
                    <span>
                      <b>To Raise :</b>
                      <b>{{ project.goalAmount / 10**18 }} ETH</b>
                    </span>
                    <span v-if="project.currentState == 1">wasn't achieved before deadline</span>
                    <span v-if="project.currentState == 2">has been achieved</span>
                    <br />
                    <br />
                    <span v-if="!project.milestonestate">
                      <b>Deadline :</b>
                      <b>{{ new Date(project.deadline * 1000) }}</b>
                    </span>
                  </div>
                </v-card-title>
                <v-flex
                  v-if="project.currentState == 0 && account != project.projectStarter"
                  class="d-flex ml-3"
                  xs12
                  sm6
                  md3
                >
                  <v-text-field
                    label="Amount (in ETH)"
                    type="number"
                    step="0.0001"
                    min="0"
                    v-model="project.fundAmount"
                  ></v-text-field>
                  <v-btn
                    dark
                    color="primary"
                    @click="fundProject(index)"
                    :loading="project.isLoading"
                  >Fund</v-btn>
                </v-flex>
                <div class="Updatemilestone">
                  <v-flex
                    v-if="project.currentState==0 && account == project.projectStarter && !project.milestonestate"
                    class="d-flex ml-3"
                    xs12
                    sm6
                  >
                    <v-flex>
                      <v-text-field
                        label="Milestone Amount (in ETH)"
                        type="number"
                        step="0.0001"
                        min="0"
                        v-model="project.milestoneAmount"
                      ></v-text-field>
                    </v-flex>
                    <v-flex>
                      <v-text-field
                        label="Duration (in days) for Milestone"
                        type="number"
                        v-model="project.period"
                      ></v-text-field>
                    </v-flex>
                    <v-flex xs12 sm6>
                      <v-btn
                        dark
                        color="primary"
                        @click="updateMilestones(index)"
                        :loading="project.milestoneloading"
                      >Update Milestone</v-btn>
                    </v-flex>
                  </v-flex>
                </div>
                <v-flex
                  v-if="project.milestonestate && project.currentState==0"
                  class="d-flex ml-3"
                  xs12
                >
                  <v-flex v-if="!project.milestonestate" sm6>
                    <b>Milestone is has been set.Look for the list of Milestones in top right corner.</b>
                  </v-flex>
                  <v-flex sm6>
                    <b>Milestone {{projectMilestoneData[index].length}} is InProgress</b>
                  </v-flex>
                  <v-flex sm6>
                    <b>Deadline:</b>

                    {{ new Date(project.deadline * 1000) }}
                  </v-flex>
                </v-flex>
                <v-card-actions v-if="project.currentState == 0" class="text-xs-center">
                  <span
                    class="font-weight-bold"
                    style="width: 200px;"
                  >{{ project.currentAmount / 10**18 }} ETH</span>
                  <v-progress-linear
                    height="10"
                    :color="stateMap[project.currentState].color"
                    :value="(project.currentAmount / project.milestonevalue) * 100"
                  ></v-progress-linear>
                  <span
                    class="font-weight-bold"
                    style="width: 200px;"
                  >{{ project.milestonevalue / 10**18 }} ETH</span>
                </v-card-actions>
                <div class="DonateReward">
                  <v-flex class="d-flex ml-3" xs12 sm6 md3>
                    <v-btn
                      dark
                      color="primary"
                      v-if="project.currentState == 1 && project.contributers.includes(account) && project.reward==true && account != project.projectStarter"
                      @click="getRefund(index)"
                      :loading="project.isLoading"
                    >Get refund</v-btn>
                  </v-flex>
                  <v-flex
                    v-if="project.currentState == 2 && project.contributers.includes(account) && project.reward==true && project.rewardstate && account != project.projectStarter"
                    v-flex
                    class="d-flex ml-3"
                    xs12
                    sm6
                    md3
                  >
                    <v-btn
                      dark
                      color="primary"
                      @click="getReward(index)"
                      :loading="project.isLoading"
                    >Get Reward</v-btn>
                  </v-flex>
                  <v-flex
                    v-if="project.currentState == 2 && project.reward==true && account == project.projectStarter"
                    v-flex
                    class="d-flex ml-3"
                    xs12
                    sm6
                    md3
                  >
                    <h3
                      v-if="project.rewardstate"
                      style="color:green"
                      class="ml-5"
                    >Reward Donated!!!</h3>
                    <v-text-field
                      v-if="!project.rewardstate"
                      label="Amount (in ETH)"
                      type="number"
                      step="0.0001"
                      min="0"
                      v-model="project.rewardAmount"
                    ></v-text-field>
                    <v-btn
                      v-if="!project.rewardstate"
                      dark
                      color="primary"
                      @click="rewardProject(index)"
                      :loading="project.isLoading"
                    >Reward</v-btn>
                  </v-flex>
                </div>
              </v-card>
            </v-hover>
          </v-flex>
        </v-layout>
      </v-container>
    </v-content>
  </v-app>
</template>

<script>
// We import our the scripts for the smart contract instantiation, and web3
import crowdfundInstance from "../contracts/crowdfundInstance";
import crowdfundProject from "../contracts/crowdfundProjectInstance";
import web3 from "../contracts/web3";

export default {
  name: "App",
  data() {
    return {
      toggle_value: false,
      startProjectDialog: false,
      account: null,
      stateMap: [
        { color: "primary", text: "Ongoing" },
        { color: "warning", text: "Expired" },
        { color: "success", text: "Completed" },
      ],
      projectData: [],
      projectMilestoneData: [],
      newProject: {
        isLoading: false,
        milestoneloading: false,
        startMilestoneDialog: false,
      },
    };
  },
  mounted() {
    // this code snippet takes the account (wallet) that is currently active
    web3.eth.getAccounts().then((accounts) => {
      [this.account] = accounts;
      this.getProjects();
    });
  },
  methods: {
    getProjects() {
      crowdfundInstance.methods
        .returnAllProjects()
        .call()
        .then((projects) => {
          projects.forEach((projectAddress) => {
            const projectInst = crowdfundProject(projectAddress);
            projectInst.methods
              .getDetails()
              .call()
              .then((projectData) => {
                const projectInfo = projectData;
                projectInfo.isLoading = false;
                projectInfo.milestoneloading = false;
                projectInfo.startMilestoneDialog = false;
                console.log(projectInfo.contributers);
                projectInfo.contract = projectInst;
                this.projectData.push(projectInfo);
              });
            projectInst.methods
              .getMilestones()
              .call()
              .then((data) => {
                const info = data;
                this.projectMilestoneData.push(info);
              });
          });
        });
    },

    startProject() {
      this.newProject.isLoading = true;
      crowdfundInstance.methods
        .startProject(
          this.newProject.title,
          this.newProject.description,
          this.newProject.duration,
          web3.utils.toWei(this.newProject.amountGoal, "ether"),
          this.newProject.reward,
          web3.utils.toWei(this.newProject.milestone, "ether")
        )
        .send({
          from: this.account,
        })
        .then((res) => {
          const projectInfo = res.events.ProjectStarted.returnValues;
          projectInfo.isLoading = false;
          projectInfo.milestoneloading = false;
          projectInfo.startMilestoneDialog = false;
          projectInfo.currentAmount = 0;
          projectInfo.currentState = 0;
          projectInfo.contract = crowdfundProject(projectInfo.contractAddress);
          this.startProjectDialog = false;
          this.newProject = {
            isLoading: false,
            milestoneloading: false,
            startMilestoneDialog: false,
          };
          location.reload(true);
        });
    },

    fundProject(index) {
      if (!this.projectData[index].fundAmount) {
        return;
      }

      const projectContract = this.projectData[index].contract;
      this.projectData[index].isLoading = true;
      projectContract.methods
        .contribute()
        .send({
          from: this.account,
          value: web3.utils.toWei(this.projectData[index].fundAmount, "ether"),
          gas:1000000
        })
        .then((res) => {
          const newTotal = parseInt(
            res.events.FundingReceived.returnValues.currentTotal,
            10
          );
          const projectGoal = parseInt(this.projectData[index].goalAmount, 10);
          this.projectData[index].currentAmount = newTotal;
          this.projectData[index].isLoading = false;

          // Set project state to success
          if (newTotal >= projectGoal) {
            this.projectData[index].currentState = 2;
          }
          location.reload(true);
        });
    },

    rewardProject(index) {
      if (!this.projectData[index].rewardAmount) {
        return;
      }

      const projectContract = this.projectData[index].contract;
      this.projectData[index].isLoading = true;
      projectContract.methods
        .donate()
        .send({
          from: this.account,
          value: web3.utils.toWei(
            this.projectData[index].rewardAmount,
            "ether"
          ),
          gas:1000000
        })
        .then((res) => {
          this.projectData[index].isLoading = false;
          location.reload(true);
        });
    },

    getRefund(index) {
      this.projectData[index].isLoading = true;
      this.projectData[index].contract.methods
        .getRefund()
        .send({
          from: this.account,
        })
        .then(() => {
          this.projectData[index].isLoading = false;
          location.reload(true);
        });
    },

    getReward(index) {
      this.projectData[index].isLoading = true;
      this.projectData[index].contract.methods
        .getReward()
        .send({
          from: this.account,
          gas:1000000
          })
        .then(() => {
          this.projectData[index].isLoading = false;
          location.reload(true);
        });
    },

    checkProgress(index) {
      this.projectData[index].isLoading = true;
      this.projectData[index].contract.methods
        .checkIfFundingCompleteOrExpired()
        .send({
          from: this.account,
        })
        .then(() => {
          this.projectData[index].isLoading = false;
          location.reload(true);
        });
    },

    updateMilestones(index) {
      if (!this.projectData[index].milestoneAmount) {
        return;
      }
      this.projectData[index].milestoneloading = true;
      this.projectData[index].contract.methods
        .updateMilestone(
          web3.utils.toWei(this.projectData[index].milestoneAmount, "ether"),
          this.projectData[index].period
        )
        .send({
          from: this.account,
        })
        .then(() => {
          this.projectData[index].milestoneloading = false;
          location.reload(true);
        });
    },
  },
};
</script>
