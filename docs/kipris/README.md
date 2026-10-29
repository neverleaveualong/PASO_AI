# KIPRIS Plus Open API 명세서 (AI & Developer Reference)

본 디렉토리는 **PASO AI**의 특허 데이터 수집·분석(PASO Lens) 및 명세서/OA 생성(PASO Docs) 파이프라인이 참조하는 **특허청 KIPRIS Plus REST Open API 공식 명세**를 정리한 문서입니다.

AI 에이전트 및 백엔드(C#) 개발 시 DTO/엔티티 설계, XML 파서 구현, DB 스키마 매핑의 단일 진실 공급원(Single Source of Truth)으로 활용합니다.

---

## 1. 기본 호출 규격 (Base Specification)

| 항목 | 내용 |
| :--- | :--- |
| **서비스명** | 국내 특허·실용신안 정보 조회 서비스 (`patUtiModInfoSearchSevice`) |
| **Base URL** | `http://plus.kipris.or.kr/kipo-api/kipi/patUtiModInfoSearchSevice/{Operation명}` |
| **HTTP Method** | `GET` |
| **응답 포맷** | `XML` (UTF-8) |
| **인증 파라미터** | `ServiceKey={발급받은_API_키}` |

> [!IMPORTANT]
> **KIPRIS API 호출 시 필수 주의사항**
> 1. **서비스명 오타 주의**: KIPRIS 공식 URL 경로에 `Service`가 아닌 `Sevice` (`patUtiModInfoSearchSevice` - `r` 누락)로 되어 있는 엔드포인트가 표준입니다.
> 2. **`ServiceKey` 파라미터 위치**: 쿼리 스트링에서 **`ServiceKey`는 반드시 가장 마지막 파라미터로 배치**해야 `SERVICE KEY IS NOT REGISTERED` 또는 `NO OPENAPI SERVICE ERROR`를 방지할 수 있습니다.
> 3. **출원번호 포맷**: 하이픈(`-`)을 제외한 **13자리 숫자 문자열**을 사용합니다. (예: `10-2023-0012345` -> `1020230012345`)

---

## 2. 공통 응답 헤더 및 에러 코드

모든 XML 응답은 `<response>` 루트 엘리먼트 아래 `<header>`와 `<body>`로 구성됩니다.

```xml
<?xml version="1.0" encoding="UTF-8"?>
<response>
    <header>
        <requestMsgID/>
        <responseTime>2026-10-30 00:01:00.123</responseTime>
        <responseMsgID/>
        <successYN>Y</successYN>
        <resultCode>00</resultCode>
        <resultMsg>NORMAL SERVICE.</resultMsg>
    </header>
    <body>
        <items>
            <!-- 오퍼레이션별 데이터 -->
        </items>
    </body>
</response>
```

| `resultCode` | `successYN` | `resultMsg` | 설명 및 대응 방법 |
| :---: | :---: | :--- | :--- |
| **`00`** | `Y` | `NORMAL SERVICE.` | 정상 응답 |
| **`01`** | `N` | `APPLICATION ERROR.` | 서버 내부 어플리케이션 오류 (재시도 처리) |
| **`10`** | `N` | `INVALID REQUEST PARAMETER ERROR.` | 필수 파라미터(`applicationNumber` 등) 누락 또는 형식 오류 |
| **`12`** | `N` | `NO OPENAPI SERVICE ERROR.` | URL 오타 또는 `ServiceKey` 순서 오류 |
| **`20`** | `N` | `SERVICE ACCESS DENIED ERROR.` | 해당 오퍼레이션 활용 신청 미승인 상태 |
| **`22`** | `N` | `LIMITED NUMBER OF SERVICE REQUESTS EXCEEDS ERROR.` | 일/월간 트래픽(호출 한도) 초과 |
| **`30`** | `N` | `SERVICE KEY IS NOT REGISTERED ERROR.` | 잘못된 `ServiceKey` 또는 URL 인코딩 이중 적용 오류 |

---

## 3. 문서 구성 (문서 인덱스)

1. **[01_SEARCH_API.md](./01_SEARCH_API.md)**
   * 키워드 및 조건별 특허 목록 검색 (`getAdvancedSearch`, `getWordSearch`)
   * PASO Lens의 선행특허 탐색 및 기술군 리스트업에 사용
2. **[02_BIBLIOGRAPHY_DETAIL_API.md](./02_BIBLIOGRAPHY_DETAIL_API.md)**
   * 출원번호 기반 서지 상세 통합 조회 (`getBibliographyDetailInfoSearch`)
   * 서지 요약, **청구항 배열(`claimInfoArray`)**, IPC/CPC, 출원인/발명자, 초록, 법적상태, 선행기술조사 문헌, 패밀리 정보 등 핵심 상세 데이터 명세
3. **[03_FULLTEXT_AND_IMAGE_API.md](./03_FULLTEXT_AND_IMAGE_API.md)**
   * 공개/등록 전문 PDF 다운로드 경로 및 대표도면 이미지 경로 조회 (`getPubFullTextInfoSearch`, `getAnnFullTextInfoSearch`)
   * PASO Docs의 전문 텍스트 추출(발명의 상세한 설명, 도면 부호 매칭)에 사용
