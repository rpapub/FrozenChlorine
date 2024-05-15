using System;
using System.Collections.Generic;
using System.Data;
using FrozenChlorine.ObjectRepository;
using LuckyLawrencium;
using UiPath.CodedWorkflows;
using UiPath.Core;
using UiPath.Core.Activities.Storage;
using UiPath.Orchestrator.Client.Models;
using UiPath.Testing;
using UiPath.Testing.Activities.TestData;
using UiPath.Testing.Activities.TestDataQueues.Enums;
using UiPath.Testing.Enums;
using UiPath.UIAutomationNext.API.Contracts;
using UiPath.UIAutomationNext.API.Models;
using UiPath.UIAutomationNext.Enums;

namespace FrozenChlorine.Framework
{
    using CalculatorApp = LuckyLawrencium.ObjectRepository.Descriptors.Calculator;

    public class InitAllApplications : CodedWorkflow
    {
        [Workflow]
        public void Execute(Dictionary<string, object> in_Config)
        {
            try
            {
                Log("Starting Execute method...");

                // Add debug logging for input configuration
//                                Log("Input configuration:");
//                                foreach (var kvp in in_Config)
//                                {
//                                    Log($"{kvp.Key}: {kvp.Value}");
//                                }

                // Check if uiAutomation is null
                if (uiAutomation == null)
                {
                    Log("Error: uiAutomation is null. Exiting...");
                    return;
                }

                Log("Before calling uiAutomation.Open method...");

                var taOptions = new TargetAppOptions();
                taOptions.OpenMode = NAppOpenMode.IfNotOpen;
                // Call uiAutomation.Open method

                //var CalculatorStandardScreen = uiAutomation.Open(CalculatorApp.Standard, taOptions);

                var CalculatorStandardScreen = uiAutomation.Open(CalculatorApp.Standard);

                Log("After calling uiAutomation.Open method...");
            }
            catch (Exception ex)
            {
                Log($"An error occurred: {ex.Message}");
            }
        }


    }
}
