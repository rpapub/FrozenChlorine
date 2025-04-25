# FrozenChlorine - Windows Calculator RPA

**FrozenChlorine** is a UiPath automation project designed to simulate and perform operations using the Windows Calculator application. It supports input parsing, UI interactions, application lifecycle handling, and robust testing.

## 🧾 Project Metadata

| Key                   | Value                                              |
|----------------------|----------------------------------------------------|
| **Name**             | FrozenChlorine                                     |
| **Description**      | RPA UiPath process automating the Windows Calculator App |
| **Studio Version**   | 23.10.0.0                                          |
| **Target Framework** | Windows                                            |
| **Main Entry Point** | `StandardCalculator.xaml`                          |
| **Project Version**  | 0.2.170780471                                      |
| **Execution Type**   | Workflow                                           |

## 📦 Dependencies

| Package                             | Version            |
|-------------------------------------|--------------------|
| `LuckyLawrencium`                  | 0.2.0              |
| `UiPath.CodedWorkflows`           | 24.4.2             |
| `UiPath.Excel.Activities`         | 2.23.3-preview     |
| `UiPath.System.Activities.Runtime`| 24.5.0-preview     |
| `UiPath.Testing.Activities`       | 24.4.0-preview     |
| `UiPath.UIAutomation.Activities.Runtime` | 24.4.2      |

## 📁 Structure Overview

- **Main Workflow**: `StandardCalculator.xaml`
- **Sub Workflows**:
  - Initialization: `InitAllApplications.xaml`, `InitAllSettings.xaml`
  - Teardown: `Teardown.xaml`, `CloseAllApplications.xaml`, `KillAllProcesses.xaml`
  - Operation Logic: `AdditionOf2Terms.xaml`, `ParseTermToList.xaml`, `ClickListOfCharacters.xaml`, `ResetCalculator.xaml`

## 📤 Inputs

- `Term1`, `Term2`: Terms to be calculated
- `Operation`: Operation type (e.g., "+", "-", "*", "/")
- `DecimalSeparator`, `ConfigFile`: Optional configuration inputs

## 📥 Output

- `Result`: The calculated result as a string

## 🚀 How to Run

1. Open the project in UiPath Studio.
2. Set the input arguments in `StandardCalculator.xaml`.
3. Run the workflow or trigger the provided test cases.

## 🧪 Test Suite

The project contains automated tests organized into four categories:

### End-to-End
- `TestCase_EndToEnd_StandardCalculator.xaml`  
  Validates the complete operation workflow, ensuring accurate calculations using the full stack.

### Unit Tests
- `TestCase_Unit_ParseTermToList.xaml`  
  Tests parsing logic for converting terms into character sequences.

### Module Tests
- `TestCase_InitAllApplications.xaml`  
  Ensures correct application initialization and environment preparation.

### GUI Tests
- `TestCase_PathKeeper.xaml`  
  UI-specific tests; JSON variant (`.xaml.json`) available for variations.
