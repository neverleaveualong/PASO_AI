# KIPRIS Plus Open API 전체 카탈로그 및 명세서

본 디렉토리는 **PASO AI**가 활용하는 특허청(지식재산처) **KIPRIS Plus Open API (전체 서비스 45건 / 오퍼레이션 437건)**의 공식 명세를 체계적으로 정리한 레퍼런스입니다.

---

## 1. KIPRIS Plus API 전체 서비스 목록 (총 45건 / 437개 오퍼레이션)

현재 확인된 핵심 서비스 목록이며, 상세 명세 문서로 연결됩니다.

| 번호 | 서비스명 | 데이터 구분 | 카테고리 | 권리 구분 | 제공 기관 | PASO AI 활용도 | 상세 명세 문서 |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :--- |
| **1** | **특허·실용 공개·등록공보** | 국내 IP데이터 | 공보 | 특허·실용 | 지식재산처 | ★★★ (핵심) | [01_PATENT_PUBLICATION_GAZETTE.md](./01_PATENT_PUBLICATION_GAZETTE.md) |
| **2** | **특허·실용 인용문헌** | 국내 IP데이터 | 부가 | 특허·실용 | 지식재산처 | ★★★ (Lens) | *작성 예정* |
| **3** | **특허·실용 행정처리 이력** | 국내 IP데이터 | 행정 | 특허·실용 | 지식재산처 | ★★★ (Docs/OA) | *작성 예정* |
| **4** | **특허·실용 분류코드 변동 이력** | 국내 IP데이터 | 행정 | 특허·실용 | 지식재산처 | ★★☆ (Lens) | *작성 예정* |
| **5** | **디자인 공보** | 국내 IP데이터 | 공보 | 디자인 | 지식재산처 | ★☆☆ (확장) | *작성 예정* |
| **6** | **디자인 행정처리 이력** | 국내 IP데이터 | 행정 | 디자인 | 지식재산처 | ★☆☆ (확장) | *작성 예정* |

---

## 2. 서비스 #1 세부 기술 문서 (특허·실용 공개·등록공보)

서비스 1번(**특허·실용 공개·등록공보**)의 3대 기능 영역별 세부 오퍼레이션 및 XML 태그 명세입니다.

* **[서비스 1 개요 및 통합 명세](./01_PATENT_PUBLICATION_GAZETTE.md)**
  * **① 검색**: [01_SEARCH_API.md](./01_SEARCH_API.md) — 일반검색 및 항목별검색 (XML)
  * **② 서지정보**: [02_BIBLIOGRAPHY_DETAIL_API.md](./02_BIBLIOGRAPHY_DETAIL_API.md) — 출원번호, 등록일자, 발명의 명칭, 청구항, 등록상태 등 상세 서지정보 (XML)
  * **③ 도면/전문**: [03_FULLTEXT_AND_IMAGE_API.md](./03_FULLTEXT_AND_IMAGE_API.md) — 공개 및 공고 전문, 대표도면 다운로드 경로 (XML)

---

## 3. 공통 호출 규격 및 에러 코드

* **전송 방식**: REST (`GET`)
* **응답 포맷**: `XML` (UTF-8)
* **인증 방식**: 쿼리 파라미터 `ServiceKey` (URL의 맨 마지막 파라미터로 배치 권장)

| `resultCode` | `successYN` | `resultMsg` | 설명 |
| :---: | :---: | :--- | :--- |
| **`00`** | `Y` | `NORMAL SERVICE.` | 정상 응답 |
| **`01`** | `N` | `APPLICATION ERROR.` | 서버 내부 어플리케이션 오류 |
| **`10`** | `N` | `INVALID REQUEST PARAMETER ERROR.` | 필수 파라미터 누락 또는 형식 오류 |
| **`12`** | `N` | `NO OPENAPI SERVICE ERROR.` | 잘못된 오퍼레이션 URL 또는 파라미터 순서 오류 |
| **`20`** | `N` | `SERVICE ACCESS DENIED ERROR.` | 서비스 이용 신청 미승인 |
| **`22`** | `N` | `LIMITED NUMBER OF SERVICE REQUESTS EXCEEDS ERROR.` | 트래픽 한도 초과 |
| **`30`** | `N` | `SERVICE KEY IS NOT REGISTERED ERROR.` | 등록되지 않은 `ServiceKey` 또는 인코딩 오류 |
