# 01. 특허·실용신안 목록 검색 API 명세 (`Search API`)

선행기술 조사 및 특정 기술 키워드/출원인/분류코드 기반 특허 리스트를 조회할 때 사용하는 API 명세입니다.

---

## 1. 항목별 상세 검색 (`getAdvancedSearch`)

* **Endpoint**: `GET http://plus.kipris.or.kr/kipo-api/kipi/patUtiModInfoSearchSevice/getAdvancedSearch`
* **용도**: 발명의 명칭, 초록, 청구범위, 출원인, IPC 코드 등 세분화된 필드를 조합하여 검색합니다.

### 1.1 요청 파라미터 (Query Parameters)

| 파라미터명 | 타입 | 필수 | 설명 | 예시 |
| :--- | :---: | :---: | :--- | :--- |
| `inventionTitle` | `string` | N | 발명의 명칭 검색어 | `인공지능 특허` |
| `astrtCont` | `string` | N | 요약(초록) 본문 검색어 | `자연어 처리` |
| `claimScope` | `string` | N | 청구범위(청구항) 내 포함 키워드 | `청구항 생성` |
| `ipcNumber` | `string` | N | IPC 분류 코드 | `G06F` |
| `applicationNumber` | `string` | N | 출원번호 (13자리 숫자) | `1020220012345` |
| `openNumber` | `string` | N | 공개번호 | `1020230012345` |
| `registerNumber` | `string` | N | 등록번호 | `1024567890000` |
| `applicationDate` | `string` | N | 출원일자 또는 기간 (`YYYYMMDD~YYYYMMDD`) | `20200101~20261231` |
| `applicant` | `string` | N | 출원인 명칭 | `삼성전자` |
| `inventors` | `string` | N | 발명자 성명 | `홍길동` |
| `patent` | `boolean` | N | 특허 포함 여부 (`true` / `false`) | `true` |
| `utility` | `boolean` | N | 실용신안 포함 여부 (`true` / `false`) | `true` |
| `lastvalue` | `string` | N | 행정처분(법적상태) 필터 (`A`: 공개, `C`: 취하, `F`: 소멸, `G`: 포기, `I`: 무효, `J`: 거절, `R`: 등록) | `R` |
| `pageNo` | `int` | N | 페이지 번호 (기본값: `1`) | `1` |
| `numOfRows` | `int` | N | 페이지당 건수 (기본값: `30`, 최대 `500`) | `50` |
| `sortSpec` | `string` | N | 정렬 기준 (`PD`: 공고일, `AD`: 출원일, `GD`: 등록일, `OPD`: 공개일) | `AD` |
| `descSort` | `boolean` | N | 내림차순 정렬 여부 (`true`: 최신순) | `true` |
| `ServiceKey` | `string` | **Y** | 오픈 API 인증키 (**반드시 맨 끝에 위치**) | `YOUR_KEY` |

---

## 2. 자유 검색어 검색 (`getWordSearch`)

* **Endpoint**: `GET http://plus.kipris.or.kr/kipo-api/kipi/patUtiModInfoSearchSevice/getWordSearch`
* **용도**: 단일 검색어(`word`)로 전체 텍스트(명칭+초록+청구항)를 통합 검색할 때 사용합니다.
* **주요 파라미터**: `word` (필수, 검색어), `patent`, `utility`, `pageNo`, `numOfRows`, `ServiceKey` (필수)

---

## 3. 응답 데이터 구조 (Response XML Fields)

`getAdvancedSearch` 및 `getWordSearch`는 동일한 `<item>` 리스트 구조를 반환합니다.

```xml
<response>
    <header>
        <successYN>Y</successYN>
        <resultCode>00</resultCode>
        <resultMsg>NORMAL SERVICE.</resultMsg>
    </header>
    <body>
        <items>
            <item>
                <indexNo>1</indexNo>
                <applicantName>주식회사 파소</applicantName>
                <applicationDate>20240315</applicationDate>
                <applicationNumber>1020240035123</applicationNumber>
                <astrtCont>본 발명은 거대언어모델(LLM)을 기반으로 특허 청구항을 분석하고...</astrtCont>
                <bigDrawing>http://plus.kipris.or.kr/kiprisplusws/fileToss.jsp?arg=...</bigDrawing>
                <drawing>http://plus.kipris.or.kr/kiprisplusws/fileToss.jsp?arg=...</drawing>
                <inventionTitle>인공지능 기반 특허 분석 및 명세서 자동 생성 시스템</inventionTitle>
                <ipcNumber>G06F 16/30|G06N 3/08</ipcNumber>
                <openDate>20250920</openDate>
                <openNumber>1020250112233</openNumber>
                <publicationDate/>
                <publicationNumber/>
                <registerDate>20260110</registerDate>
                <registerNumber>1026123450000</registerNumber>
                <registerStatus>등록</registerStatus>
            </item>
        </items>
        <count>
            <numOfRows>30</numOfRows>
            <pageNo>1</pageNo>
            <totalCount>142</totalCount>
        </count>
    </body>
</response>
```

### 3.1 `<item>` 필드 상세 명세

| XML 태그명 | 타입 | 설명 | DB 설계 시 참고사항 |
| :--- | :---: | :--- | :--- |
| `indexNo` | `int` | 검색 결과 순번 | 저장 불필요 (화면 표시용) |
| `applicationNumber` | `string(13)` | **출원번호 (고유 식별 키 후보)** | `VARCHAR(20)`, Unique Index 필수 |
| `applicationDate` | `string(8)` | 출원일자 (`YYYYMMDD`) | `DATE` 타입으로 변환 저장 |
| `inventionTitle` | `string` | 발명의 명칭 (국문) | `TEXT` 또는 `VARCHAR(500)` |
| `astrtCont` | `string` | 요약(초록) 전문 | `TEXT` (벡터 임베딩 대상 1순위) |
| `applicantName` | `string` | 출원인 명칭 | 복수일 경우 파이프(`\|`) 또는 세미콜론 구분 가능 |
| `ipcNumber` | `string` | IPC 분류 코드 목록 | 파이프(`\|`)로 구분된 문자열 (상세 조회에서 정규화) |
| `openNumber` | `string(13)` | 공개번호 | 미공개 시 빈 값(`null`) |
| `openDate` | `string(8)` | 공개일자 (`YYYYMMDD`) | 미공개 시 빈 값(`null`) |
| `registerNumber` | `string(13)` | 등록번호 | 미등록 시 빈 값(`null`) |
| `registerDate` | `string(8)` | 등록일자 (`YYYYMMDD`) | 미등록 시 빈 값(`null`) |
| `registerStatus` | `string` | 현재 법적 상태 한글명 | 예: `등록`, `공개`, `거절`, `취하`, `소멸`, `포기` |
| `drawing` | `string(URL)` | 썸네일 대표도면 이미지 URL | 이미지 프록시 또는 스토리지 캐싱 고려 |
| `bigDrawing` | `string(URL)` | 원본 크기 대표도면 이미지 URL | `TEXT` |
| `totalCount` | `int` | 전체 검색 결과 건수 (`<count>` 하위) | 페이징 계산용 |
