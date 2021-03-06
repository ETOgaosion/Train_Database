<?php

use app\tools\Session;
use app\controllers\ViewCtrl;

ViewCtrl::includePageHeader(array('pageTitle' => "query_res", 'assetsDir' => "assets/", 'login' => true));
$assetsDir = 'assets/';
if (!isset($date)) {
    $date = date('Y-m-d', time());
}
if (!isset($date)) {
    $time = date('H:i', time());;
}
if (!isset($start_city)) {
    $start_city = "北京";
}
if (!isset($end_city)) {
    $end_city = "郑州";
}
if (!isset($queryRes)) {
    $queryRes = array();
}
?>

    <!-- free map api: OpenLayers -->
    <!-- Map css api link -->
    <link href="https://cdn.jsdelivr.net/gh/openlayers/openlayers.github.io@master/en/v6.14.1/css/ol.css"
          rel="stylesheet"
          type="text/css">

    <!-- Map js api link -->
    <script src="https://cdn.jsdelivr.net/gh/openlayers/openlayers.github.io@master/en/v6.14.1/build/ol.js"
            type="text/javascript"></script>

    <div class="d-flex align-items-center justify-content-center position-absolute start-0 end-0"
         style="top: 75px; bottom: 100px">
        <form class="h-100 w-75 d-flex flex-column align-items-center justify-content-start bg-light p-5"
             style="--bs-bg-opacity: 0.8" method="post" action="userPostGenerateOrder" id="queryTrainByCityForm" name="queryTrainByCityForm">
            <div class="row flex-row justify-content-center align-items-center w-100" style="height: 50px;">
                <p class="fs-2 fw-bold text-center">车次查询信息</p>
            </div>
            <div class="row w-100" style="height: 25%">
                <div class="col w-50 h-100 p-3">
                    <div class="row w-100" style="height: 200px;">
                        <div class="row flex-column justify-content-center align-items-center w-100 ps-5">
                            <div class="row justify-content-start">
                                <p>Date: <?= $date ?></p>
                            </div>
                            <div class="row justify-content-start">
                                <p>Time: <?= $time ?></p>
                            </div>
                            <div class="row justify-content-start">
                                <p>起始城市: <?= $start_city ?> &nbsp; ~ &nbsp; 目的城市：<?= $end_city ?></p>
                            </div>
                            <div class="row justify-content-start">
                                <button type="submit" formmethod="post" formaction="userPostGenerateOrder" class="btn btn-primary w-50"
                                        form="queryTrainByCityForm">Submit
                                </button>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="col w-50 h-100 p-3">
                    <div id="map" class="map h-100 w-100"></div>
                </div>
            </div>
            <hr/>
            <div class="row w-100" style="height: 70%; overflow: scroll">
                <table class="table-striped table-bordered border-secondary">
                    <thead>
                    <tr>
                        <th scope="col" class="text-center">车次编号</th>
                        <th scope="col" class="text-center">起始站</th>
                        <th scope="col" class="text-center">目的站</th>
                        <th scope="col" class="text-center">发时</th>
                        <th scope="col" class="text-center">到时</th>
                        <th scope="col" class="text-center">历时</th>
                        <th scope="col" class="text-center">里程</th>
                        <th scope="col" class="text-center">换乘上半</th>
                        <th scope="col" class="text-center">换乘下半</th>
                        <th scope="col" class="text-center">座位类型</th>
                        <!--                    <th colspan="2"">-->
                        <!--                    <div class="dropdown d-flex flex-row justify-content-center align-items-center">-->
                        <!--                        <button class="btn btn-primary w-100" disabled="true"d id="seatTypeBtn" style="border-bottom-right-radius:0; border-top-right-radius: 0;">座位</button>-->
                        <!--                        <button class="btn btn-primary dropdown-toggle dropdown-toggle-split" style="border-top-left-radius: 0; border-bottom-left-radius: 0" href="#" role="button" id="dropDownSeatTypeBtn" data-bs-toggle="dropdown" aria-expanded="false">-->
                        <!--                            <span class="visually-hidden"></span>-->
                        <!--                        </button>-->
                        <!--                        <ul class="dropdown-menu">-->
                        <!--                            <li><button class="dropdown-item" onclick="switchSeatToHardSeat();" id="hardSeatDpItem"">硬座</button></li>-->
                        <!--                            <li><button class="dropdown-item" onclick="switchSeatToSoftSeat();" id="softSeatDpItem"">软座</button></li>-->
                        <!--                            <li><button class="dropdown-item" onclick="switchSeatToHardBedTop();" id="hardBedTopDpItem"">硬卧上</button></li>-->
                        <!--                            <li><button class="dropdown-item" onclick="switchSeatToHardBedMid();" id="hardBedMidDpItem"">硬卧中</button></li>-->
                        <!--                            <li><button class="dropdown-item" onclick="switchSeatToHardBedDown();" id="hardBedDownDpItem"">硬卧下</button></li>-->
                        <!--                            <li><button class="dropdown-item" onclick="switchSeatToSoftBedTop();" id="softBedTopDpItem"">软卧上</button></li>-->
                        <!--                            <li><button class="dropdown-item" onclick="switchSeatToSoftBedDown();" id="softBedDownDpItem"">软卧下</button></li>-->
                        <!--                        </ul>-->
                        <!--                    </div>-->
                        <!--                    </th>-->
                        <!--                </tr>-->
                        <!--                <tr>-->
                        <th scope="col" class="text-center">票价</th>
                        <th scope="col" class="text-center">余票</th>
                        <th scope="col" class="text-center">选择</th>
                    </tr>
                    </thead>
                    <tbody>
                    <?php
                    $startDateList = array_column($queryRes, 'start_date');
                    $arriveDateList = array_column($queryRes, 'arrive_date');
                    $trainNameList = array_column($queryRes, 'train_name');
                    $trainIdList = array_column($queryRes, 'train_id');
                    $stationFromList = array_column($queryRes, 'station_from_name');
                    $stationFromIdList = array_column($queryRes, 'station_from_id');
                    $stationToList = array_column($queryRes, 'station_to_name');
                    $stationToIdList = array_column($queryRes, 'station_to_id');
                    $leaveTimeList = array_column($queryRes, 'leave_time');
                    $arriveTimeList = array_column($queryRes, 'arrive_time');
                    $duranceList = array_column($queryRes, 'durance');
                    $distanceList = array_column($queryRes, 'distance');
                    $seatPriceList = array_column($queryRes, 'seat_prices');
                    $seatNumList = array_column($queryRes, 'seat_nums');
                    $transferFirstList = array_column($queryRes, 'transfer_first');
                    $transferLateList = array_column($queryRes, 'transfer_late');
                    $seatTypeList = array("硬座", "软座", "硬卧上", "硬卧中", "硬卧下", "软卧上", "软卧下");
                    for ($i = 0; $i < count($trainNameList); $i++) {
                        $seatPriceListArray = explode(',', substr($seatPriceList[$i], 1, strlen($seatPriceList[$i]) - 2));
                        $seatNumListArray = explode(',', substr($seatNumList[$i], 1, strlen($seatNumList[$i]) - 2));
                        for ($j = 0; $j < 7; $j++) {
                            if ($seatNumListArray[$j] == 0) {
                                continue;
                            }
                            if ($transferFirstList[$i] == 'f' && $transferLateList[$i] == 'f') {
                                echo <<<END
                <tr>
                    <td><a href="userQueryTrain?trainName={$trainNameList[$i]}&date={$date}">$trainNameList[$i]</a></td>
                    <td>$startDateList[$i]</td>
                    <td>$arriveDateList[$i]</td>
                    <td>$stationFromList[$i]</td>
                    <td>$stationToList[$i]</td>
                    <td>$leaveTimeList[$i]</td>
                    <td>$arriveTimeList[$i]</td>
                    <td>$duranceList[$i]</td>
                    <td>$distanceList[$i]</td>
                    <td>$transferFirstList[$i]</td>
                    <td>$transferLateList[$i]</td>
                    <td>$seatTypeList[$j]</td>
                    <td id="seat-type-{$j}">$seatPriceListArray[$j]</td>
                    <td id="seat-type-{$j}"><a href="userGenerateOrder?trainId={$trainIdList[$i]}&trainName={$trainNameList[$i]}&stationFromId={$stationFromIdList[$i]}&stationFrom={$stationFromList[$i]}&stationToId={$stationToIdList[$i]}&stationTo={$stationToList[$i]}&seat_type={$j}&order_date={$startDateList[$i]}">$seatNumListArray[$j]</a></td>
                    <td>
                    <div class="form-check">
                    <input class="form-check-input" type="checkbox" value="Yes" id="seat-type-{$i}-{$j}-check"  name="seat-type-{$i}-{$j}-check"  name="seat-type-{$i}-{$j}-check">
                    <input type="hidden" disabled="true" value="$startDateList[$i]" name="seat-type-{$i}-{$j}-startDate">
                    <input type="hidden" disabled="true" value="$trainNameList[$i]" name="seat-type-{$i}-{$j}-trainName">
                    <input type="hidden" disabled="true" value="$trainIdList[$i]" name="seat-type-{$i}-{$j}-trainId">
                    <input type="hidden" disabled="true" value="$stationFromIdList[$i]" name="seat-type-{$i}-{$j}-stationFromId">
                    <input type="hidden" disabled="true" value="$stationFromList[$i]" name="seat-type-{$i}-{$j}-stationFrom">
                    <input type="hidden" disabled="true" value="$stationToIdList[$i]" name="seat-type-{$i}-{$j}-stationToId">
                    <input type="hidden" disabled="true" value="$stationToList[$i]" name="seat-type-{$i}-{$j}-stationTo">
                    <input type="hidden" disabled="true" value="$j" name="seat-type-{$i}-{$j}-seat_type">
                    <input type="hidden" disabled="true" value="$startDateList[$i]" name="seat-type-{$i}-{$j}-order_date">
                    </div>
                    </td>
                </tr>
END;
                            }
                            elseif ($transferFirstList[$i] == 'f' && $transferLateList[$i] == 't') {
                                    echo <<<END
                <tr>
                    <td class="text-success"><a href="userQueryTrain?trainName={$trainNameList[$i]}&date={$date}">$trainNameList[$i]</a>></td>
                    <td class="text-success">$stationFromList[$i]</td>
                    <td class="text-success">$stationToList[$i]</td>
                    <td class="text-success">$leaveTimeList[$i]</td>
                    <td class="text-success">$arriveTimeList[$i]</td>
                    <td class="text-success">$duranceList[$i]</td>
                    <td class="text-success">$distanceList[$i]</td>
                    <td class="text-success">$transferFirstList[$i]</td>
                    <td class="text-success">$transferLateList[$i]</td>
                    <td class="text-success">$seatTypeList[$j]</td>
                    <td class="text-success" id="seat-type-{$j}">$seatPriceListArray[$j]</td>
                    <td class="text-success" id="seat-type-{$j}"><a href="userGenerateOrder?trainId={$trainIdList[$i]}&trainName={$trainNameList[$i]}&stationFromId={$stationFromIdList[$i]}&stationFrom={$stationFromList[$i]}&stationToId={$stationToIdList[$i]}&stationTo={$stationToList[$i]}&seat_type={$j}&order_date={$date}">$seatNumListArray[$j]</a></td>
                    <td>
                    <div class="form-check">
                    <input class="form-check-input" type="checkbox" value="Yes" id="seat-type-{$i}-{$j}-check"  name="seat-type-{$i}-{$j}-check"  name="seat-type-{$i}-{$j}-check">
                    <input type="hidden" disabled="true" value="$startDateList[$i]" name="seat-type-{$i}-{$j}-startDate">
                    <input type="hidden" disabled="true" value="$trainNameList[$i]" name="seat-type-{$i}-{$j}-trainName">
                    <input type="hidden" disabled="true" value="$trainIdList[$i]" name="seat-type-{$i}-{$j}-trainId">
                    <input type="hidden" disabled="true" value="$stationFromIdList[$i]" name="seat-type-{$i}-{$j}-stationFromId">
                    <input type="hidden" disabled="true" value="$stationFromList[$i]" name="seat-type-{$i}-{$j}-stationFrom">
                    <input type="hidden" disabled="true" value="$stationToIdList[$i]" name="seat-type-{$i}-{$j}-stationToId">
                    <input type="hidden" disabled="true" value="$stationToList[$i]" name="seat-type-{$i}-{$j}-stationTo">
                    <input type="hidden" disabled="true" value="$j" name="seat-type-{$i}-{$j}-seat_type">
                    <input type="hidden" disabled="true" value="$startDateList[$i]" name="seat-type-{$i}-{$j}-order_date">
                    </div>
                    </td>
                </tr>
END;
                                }
                            elseif ($transferFirstList[$i] == 't' && $transferLateList[$i] == 'f') {
                                echo <<<END
                <tr>
                    <td class="text-danger"><a href="userQueryTrain?trainName={$trainNameList[$i]}&date={$date}">$trainNameList[$i]</a></td>
                    <td class="text-danger">$stationFromList[$i]</td>
                    <td class="text-danger">$stationToList[$i]</td>
                    <td class="text-danger">$leaveTimeList[$i]</td>
                    <td class="text-danger">$arriveTimeList[$i]</td>
                    <td class="text-danger">$duranceList[$i]</td>
                    <td class="text-danger">$distanceList[$i]</td>
                    <td class="text-danger">$transferFirstList[$i]</td>
                    <td class="text-danger">$transferLateList[$i]</td>
                    <td class="text-danger">$seatTypeList[$j]</td>
                    <td class="text-danger" id="seat-type-{$j}">$seatPriceListArray[$j]</td>
                    <td class="text-danger" id="seat-type-{$j}"><a href="userGenerateOrder?trainId={$trainIdList[$i]}&trainName={$trainNameList[$i]}&stationFromId={$stationFromIdList[$i]}&stationFrom={$stationFromList[$i]}&stationToId={$stationToIdList[$i]}&stationTo={$stationToList[$i]}&seat_type={$j}&order_date={$date}">$seatNumListArray[$j]</a></td>
                    <td>
                    <div class="form-check">
                    <input class="form-check-input" type="checkbox" value="Yes" id="seat-type-{$i}-{$j}-check"  name="seat-type-{$i}-{$j}-check"  name="seat-type-{$i}-{$j}-check">
                    <input type="hidden" disabled="true" value="$startDateList[$i]" name="seat-type-{$i}-{$j}-startDate">
                    <input type="hidden" disabled="true" value="$trainNameList[$i]" name="seat-type-{$i}-{$j}-trainName">
                    <input type="hidden" disabled="true" value="$trainIdList[$i]" name="seat-type-{$i}-{$j}-trainId">
                    <input type="hidden" disabled="true" value="$stationFromIdList[$i]" name="seat-type-{$i}-{$j}-stationFromId">
                    <input type="hidden" disabled="true" value="$stationFromList[$i]" name="seat-type-{$i}-{$j}-stationFrom">
                    <input type="hidden" disabled="true" value="$stationToIdList[$i]" name="seat-type-{$i}-{$j}-stationToId">
                    <input type="hidden" disabled="true" value="$stationToList[$i]" name="seat-type-{$i}-{$j}-stationTo">
                    <input type="hidden" disabled="true" value="$j" name="seat-type-{$i}-{$j}-seat_type">
                    <input type="hidden" disabled="true" value="$startDateList[$i]" name="seat-type-{$i}-{$j}-order_date">
                    </div>
                    </td>
                </tr>
END;
                            }
                        }
                    }
                    ?>
                    </tbody>
                </table>
            </div>
            <input type="hidden" value="<?php echo count($trainNameList); ?>" name="count">
        </form>
    </div>

    <!-- free map api: OpenLayers -->
    <!-- File js link -->
    <script src="<?= $assetsDir ?>js/mapAPI.js"></script>

    <!-- File js link -->
    <script src="<?= $assetsDir ?>js/userQueryRes.js"></script>

<?php
ViewCtrl::includePageFooter();
?>