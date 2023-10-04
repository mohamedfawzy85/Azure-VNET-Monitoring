# Azure Function for VNet Utilization Monitoring

## Overview

This Azure Function is designed to monitor the utilization of Virtual Networks (VNets) in your Azure environment. It collects data about each subnet within your VNets, including the total number of IP addresses, used IP addresses, and available IP addresses. Additionally, it evaluates a specific condition: whether the used IP count in a subnet is greater than or equal to 80% of the total IP count for that subnet. If this condition is met, it assigns a value of 1; otherwise, it assigns a value of 0.

## Purpose

The primary purpose of this function is to provide insights into VNet utilization. By analyzing the utilization of subnets within your VNets, you can proactively manage and allocate resources, ensuring that your Azure environment operates efficiently.

## How it Works

1. The Azure Function is triggered on a predefined schedule.
2. It authenticates using Managed Identity, ensuring secure access to Azure resources.
3. It retrieves information about all Virtual Networks (VNets) in your Azure environment.
4. For each VNet, it iterates through its subnets and calculates the total, used, and available IP counts.
5. It evaluates whether the used IP count in a subnet is greater than or equal to 80% of the total IP count for that subnet.
6. Based on the evaluation, it assigns a value (1 for true, 0 for false) to indicate whether the condition is met.
7. The collected data, including subnet information and condition values, is sent to Log Analytics via the Data Collection Rule (DCR) endpoint.
8. You can analyze this data in Log Analytics to monitor VNet utilization and take necessary actions.

## Prerequisites

- Azure subscription.
- Azure Function App with appropriate permissions.
- Log Analytics workspace for data storage and analysis.

## Configuration

Before using this function, you need to configure the following settings:

- Azure Function environment variables.
- Log Analytics workspace settings.

## Usage

This function is scheduled to run at predefined intervals and requires minimal user interaction. Ensure that it is correctly configured and deployed to your Azure environment.

## Outputs

The function generates data that includes subnet information and condition values (1 or 0), which can be analyzed in Log Analytics to monitor VNet utilization.

## License

[Specify the license for your code, e.g., MIT License.]

## Author

[Your Name or Organization Name]


