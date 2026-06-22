# Project 2: Dual Configurable Counters (雙獨立可配置計數器系統)

## 項目簡介 (Project Description)

本項目為 FPGA 數位電路設計之 **Project 2：設計兩個完全獨立且可動態配置的計數器系統**。

系統由一個頂層連接模組（Top Module）架接兩個相同架構的子模組計數器（Counter A & B）。這兩個計數器具備極高的硬體獨立性與並行處理能力，允許使用者透過外部輸入訊號，在不重新編譯電路且互不干擾的前提下，各別即時變更計數器 A 與 B 的計數範圍（上下限）、計數方向（上數/下數）以及啟動/暫停狀態，完美達成動態線上配置的硬體設計需求。

---

## 🛠️ 硬體架構圖 (Block Diagram)

本專案架構採用 Mermaid 語法繪製，原生支援 GitHub 深色與淺色主題切換。

```mermaid
flowchart LR
    %% 全域訊號
    clk([外部時脈 clk])
    rst([外部重置 rst])

    subgraph dual_counter_top [頂層連接模組: dual_counter_top]
        %% Counter A
        subgraph Counter_A [Counter_Instance_A]
            direction TB
            CA_logic[configurable_counter 核心邏輯<br/>- 獨立 A 區間運算<br/>- 獨立 A 方向切換]
        end

        %% Counter B
        subgraph Counter_B [Counter_Instance_B]
            direction TB
            CB_logic[configurable_counter 核心邏輯<br/>- 獨立 B 區間運算<br/>- 獨立 B 方向切換]
        end
    end

    %% 連線：全域訊號分配
    clk ---> Counter_A
    clk ---> Counter_B
    rst ---> Counter_A
    rst ---> Counter_B

    %% 連線：Counter A 獨立控制
    en_A[en_A 致能] ---> Counter_A
    up_A[up_A 方向] ---> Counter_A
    low_A[low_A 下限] ---> Counter_A
    high_A[high_A 上限] ---> Counter_A
    Counter_A ---> out_A([out_A 4-bit 輸出])

    %% 連線：Counter B 獨立控制
    en_B[en_B 致能] ---> Counter_B
    up_B[up_B 方向] ---> Counter_B
    low_B[low_B 下限] ---> Counter_B
    high_B[high_B 上限] ---> Counter_B
    Counter_B ---> out_B([out_B 4-bit 輸出])

```

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
* **Counter A**：配置為 `en_A = '1'`，`up_A = '1'`（上數），初始範圍 `0000` 到 `1001`（0 至 9）。運作至 300ns 時，在不重置電路的狀態下**動態修改**範圍為 `0010` 到 `0101`（2 至 5）。
* **Counter B**：配置為 `en_B = '1'`，`up_B = '0'`（下數），範圍 `1100` 到 `0011`（12 至 3）。



---

## 模擬環境與運行指引 (How to Run)

* 將 `configurable_counter.vhd` 與 `dual_counter_top.vhd` 檔案加入至 Xilinx Vivado 專案的 Design Sources 中。
* 將 `tb_dual_counter.vhd` 加入至 Simulation Sources 中。
* 在 Vivado 左側選單點擊 **Run Simulation -> Run Behavioral Simulation**。
* **觀察波形**：
1. **前 300ns**：驗證 `out_A` 在 0 至 9 之間循環遞增；同時 `out_B` 在 12 至 3 之間循環遞減，兩者完全獨立並行。
2. **300ns 之後**：驗證 `out_A` 是否在無重置（No Reset）的狀態下，立刻自動適應新邊界，限縮在 2 至 5 之間進行循環上數，以驗證系統具備即時動態配置之能力。
