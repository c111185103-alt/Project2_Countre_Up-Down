# Project 2: Dual Configurable Counters (雙獨立可配置計數器系統)

## 項目簡介 (Project Description)
本項目為 FPGA 數位電路設計之 **Project 2：設計兩個完全獨立且可動態配置的計數器系統**。

系統由一個頂層連接模組（Top Module）架接兩個相同架構的子模組計數器（Counter A & B）。這兩個計數器具備極高的硬體獨立性與並行處理能力，允許使用者透過外部輸入訊號，在不重新編譯電路且互不干擾的前提下，各別即時變更計數器 A 與 B 的計數範圍（上下限）、計數方向（上數/下數）以及啟動/暫停狀態。

---

## Project 2 Breakdown
![Project2_Breakdown](./project2_diagram/Breakdown.drawio(1).png)

---

## 模組設計說明 (Module Specifications)

### 1. 可配置計數器模組 (`configurable_counter.vhd`)

* **動態邊界**：支援透過外部輸入即時變更計數下限（`lower_bound`）與上限（`upper_bound`）。
* **方向控制**：藉由 `up_down` 訊號控制計數器為正向上數（1）或反向下數（0）。
* **自動邊界判定**：當計數值抵達或超出設定的上限或下限時，內部組合邏輯會自動執行 Wrap-around（歸繞）回到對應的起始點，防止數值溢位。

### 2. 頂層控制模組 (`dual_counter_top.vhd`)

* **結構化建模**：採用 Structural 建模，在硬體架構內實體化兩個獨立的計數器核心（Counter_A 與 Counter_B）。
* **完全並行隔離**：將 A 與 B 的控制訊號（使能、方向、上下限）完全實體隔離，確保兩個計數器在同一個時脈驅動下可以並行運算、互不干擾。

### 3. 測試平台 (`tb_dual_counter.vhd`)

* **時脈模擬**：產生週期為 10ns（頻率 100MHz）的系統時脈。
* **硬體測試配置**：
* **Counter A**：配置為 `en_A = '1'`，`up_A = '0'`（反向下數），初始範圍 `0000` 到 `1001`（0 至 9）。
* **Counter B**：配置為 `en_B = '1'`，`up_B = '1'`（正向上數），範圍 `0011` 到 `1100`（3 至 12，即十六進制的 3 至 c）。



---

## 繞線後時序延遲分析 (Post-Routing Timing Analysis)

本專案除了進行基本的行為功能模擬外，進一步通過了 Vivado 的 **Post-Implementation Timing Simulation（實體佈線後時序模擬）**，以驗證電路在實際 FPGA 晶片硬體路徑上的真實表現。

### 功能模擬與時序模擬之對比

透過模擬波形比對，可以清楚觀察到理想硬體與真實硬體之間的關鍵差異：

| 評比項目 | Behavioral Simulation (功能模擬) | Post-Implementation Timing (繞線後時序模擬) |
| --- | --- | --- |
| **延遲模型** | **零延遲 (Zero Delay)**訊號變化與時脈正緣完全同步。 | **真實延遲 (Realistic Delay)**包含邏輯閘延遲 (Gate Delay) 與連線延遲 (Routing Delay)。 |
| **訊號觸發** | 當 `clk` 升起時，輸出值（`out_A`, `out_B`）在同一時間點完成切換（如 140.000ns）。 | 當 `clk` 升起後，輸出值需要經過一段傳播時間（Propagation Delay）才會完成轉變。 |
| **初始不確定態** | 模擬剛開始時，所有暫存器直接進入乾淨的初始值。 | 在重置訊號（`rst`）尚未穩定傳播、硬體尚未就緒前，輸出端會短暫出現**紅色不可知狀態（X 態）**。 |

### 真實硬體延遲觀測點

在繞線後的時序波形圖中（例如游標鎖定的 **264.600ns** 時間點）：

1. **傳播延遲顯現**：當前級時脈正緣（Rising Edge）升起後，輸出訊號 `out_A` 與 `out_B` 並非瞬間改變，而是存在微小的時間差（$T_{co}$，Clock-to-Output Delay）。這是因為訊號必須通過 FPGA 內部的查找表（LUT）與實際的金屬走線（Routing Net）。
2. **硬體穩健性驗證**：儘管動態配置的上下限比較邏輯較為複雜，但在 100MHz (10ns) 的時脈週期下，所有的資料建立時間（Setup Time）與保持時間（Hold Time）均未發生違規（Timing Violation），輸出波形無毛邊（Glitch），證明實體電路繞線後具備極高的穩定度。

---

## 模擬環境與運行指引 (How to Run)

* 將 `configurable_counter.vhd` 與 `dual_counter_top.vhd` 檔案加入至 Xilinx Vivado 專案的 Design Sources 中。
* 將 `tb_dual_counter.vhd` 加入至 Simulation Sources 中。
* 在 Vivado 左側選單點擊 **Run Simulation -> Run Behavioral Simulation** 觀察理想功能波形。
* 點擊 **Run Simulation -> Run Post-Implementation Timing Simulation** 驗證實體佈線後的真實硬體時序與走線延遲。
* **波形觀察重點**：
1. 驗證 `out_A` 是否在 9 到 0 之間循環遞減（下數）；同時 `out_B` 在 3 到 12 (`c`) 之間循環遞增（上數），兩者完全獨立並行。
2. 在時序模擬中，放大時脈正緣處，確認輸出訊號在時脈上升後有正常的硬體繞線延遲（Propagation Delay）且無數位毛邊。



```

```
