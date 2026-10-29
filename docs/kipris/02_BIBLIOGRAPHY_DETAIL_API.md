# 02. 서지 상세 및 청구항 통합 조회 API 명세 (`getBibliographyDetailInfoSearch`)

특정 특허(`applicationNumber`) 1건에 대한 **모든 서지 정보, 전체 청구항(`claimInfoArray`), IPC/CPC 코드, 출원인/발명자, 인용문헌, 법적상태, 패밀리 정보**를 한 번에 가져오는 가장 핵심적인 API입니다.

---

## 1. 기본 정보

* **Endpoint**: `GET http://plus.kipris.or.kr/kipo-api/kipi/patUtiModInfoSearchSevice/getBibliographyDetailInfoSearch`
* **요청 파라미터**:
  * `applicationNumber` (`string`, 필수): 13자리 출원번호 (예: `1020060070818`)
  * `ServiceKey` (`string`, 필수): 오픈 API 인증키 (마지막 위치)

---

## 2. 응답 XML 전체 구조 개요

`<item>` 내부에 용도별로 **9개의 주요 Array 컨테이너**가 중첩되어 반환됩니다.

```xml
<response>
  <header>...</header>
  <body>
    <item>
      <biblioSummaryInfoArray>...</biblioSummaryInfoArray>           <!-- 1. 서지 요약 정보 -->
      <ipcInfoArray>...</ipcInfoArray>                               <!-- 2. IPC 분류 코드 배열 -->
      <cpcInfoArray>...</cpcInfoArray>                               <!-- 3. CPC 분류 코드 배열 -->
      <abstractInfoArray>...</abstractInfoArray>                     <!-- 4. 초록(요약) 정보 -->
      <claimInfoArray>...</claimInfoArray>                           <!-- 5. 청구범위(청구항) 배열 ★핵심 -->
      <applicantInfoArray>...</applicantInfoArray>                   <!-- 6. 출원인 정보 배열 -->
      <inventorInfoArray>...</inventorInfoArray>                     <!-- 7. 발명자 정보 배열 -->
      <agentInfoArray>...</agentInfoArray>                           <!-- 8. 대리인 정보 배열 -->
      <priorityInfoArray>...</priorityInfoArray>                     <!-- 9. 우선권 주장 정보 배열 -->
      <legalStatusInfoArray>...</legalStatusInfoArray>               <!-- 10. 행정처분/법적상태 이력 배열 -->
      <priorArtDocumentsInfoArray>...</priorArtDocumentsInfoArray>   <!-- 11. 선행기술조사 인용문헌 배열 -->
      <familyInfoArray>...</familyInfoArray>                         <!-- 12. 패밀리 특허 배열 -->
    </item>
  </body>
</response>
```

---

## 3. 하위 컨테이너별 상세 필드 명세

### 3.1 `biblioSummaryInfoArray` > `biblioSummaryInfo` (서지 요약 단건)

| XML 태그명 | 설명 | 예시 값 |
| :--- | :--- | :--- |
| `applicationNumber` | 출원번호 | `10-2024-0035123` 또는 `1020240035123` |
| `applicationDate` | 출원일자 | `2024.03.15` 또는 `20240315` |
| `inventionTitle` | 발명의 국문 명칭 | `인공지능 기반 특허 분석 시스템` |
| `inventionTitleEng` | 발명의 영문 명칭 | `AI-BASED PATENT ANALYSIS SYSTEM` |
| `openNumber` | 공개번호 | `10-2025-0112233` |
| `openDate` | 공개일자 | `2025.09.20` |
| `registerNumber` | 등록번호 | `10-2612345-0000` |
| `registerDate` | 등록일자 | `2026.01.10` |
| `registerStatus` | 등록/법적 상태 | `등록` |
| `publicationNumber` | 공고번호 | `10-2026-0001234` |
| `publicationDate` | 공고일자 | `2026.01.15` |
| `originalApplicationKind` | 출원 구분 (신규/분할/변경 등) | `신규출원` |
| `OriginalExaminationRequestDate` | 심사청구일자 | `2024.03.15` |
| `claimCount` | 전체 청구항 수 | `12` |
| `finalDisposal` | 최종처분 결과 | `등록결정` |

> [!NOTE]
> `getBibliographyDetailInfoSearch`의 날짜나 번호 필드에는 마침표(`.`)나 하이픈(`-`)이 섞여서 내려오는 경우가 있으므로, C# 파서에서 숫자만 정규화(`Regex.Replace(val, @"[^0-9]", "")`)하여 DB에 저장하는 것이 안전합니다.

---

### 3.2 `claimInfoArray` > `claimInfo` (청구항 배열 - **PASO AI 핵심 데이터**)

특허의 권리 범위를 나타내는 각 청구항이 `<claimInfo>` 엘리먼트 리스트로 반환됩니다.

```xml
<claimInfoArray>
    <claimInfo>
        <claim>1. 사용자 단말로부터 기술 키워드를 입력받는 입력부; 및 상기 기술 키워드를 기반으로...</claim>
    </claimInfo>
    <claimInfo>
        <claim>2. 제1항에 있어서, 상기 분석부는 청구항 간의 인용 관계를 그래프 구조로...</claim>
    </claimInfo>
</claimInfoArray>
```

| XML 태그명 | 설명 | AI / 파서 처리 포인트 |
| :--- | :--- | :--- |
| `claim` | 개별 청구항 텍스트 전문 (번호 포함) | 1. 앞부분의 청구항 번호(`1.`, `청구항 1` 등)를 파싱해 `claim_number` 정수 컬럼으로 분리<br>2. 본문 내 `"제N항에 있어서"` 또는 `"제N항 내지 제M항"` 패턴을 정규식으로 추출해 **독립항(`Independent`) / 종속항(`Dependent`) 여부**와 **부모 청구항 번호(`parent_claim_numbers`)**를 구조화<br>3. 삭제된 청구항(`삭제`) 여부 판별 |

---

### 3.3 `abstractInfoArray` > `abstractInfo` (초록 정보)

| XML 태그명 | 설명 |
| :--- | :--- |
| `astrtCont` | 특허 요약서(초록) 전문 텍스트 |

---

### 3.4 `ipcInfoArray` > `ipcInfo` & `cpcInfoArray` > `cpcInfo` (기술 분류 코드)

| 컨테이너 | XML 태그명 | 설명 | 예시 |
| :--- | :--- | :--- | :--- |
| `ipcInfo` | `ipcNumber` | 국제특허분류(IPC) 코드 | `G06F 16/30` |
| `ipcInfo` | `ipcDate` | IPC 버전 일자 | `20190101` |
| `cpcInfo` | `cooperativePatentClassificationNumber` | 선진특허분류(CPC) 코드 | `G06F 16/334` |
| `cpcInfo` | `cooperativePatentClassificationDate` | CPC 버전 일자 | `201901` |

---

### 3.5 `applicantInfoArray` > `applicantInfo` (출원인 배열)

공동 출원이 가능하므로 `1:N` 배열로 제공됩니다.

| XML 태그명 | 설명 | 예시 |
| :--- | :--- | :--- |
| `name` | 출원인 성명/법인명 (국문) | `주식회사 파소` |
| `engName` | 출원인 영문명 | `PASO Co., Ltd.` |
| `code` | 특허고객번호 (출원인 고유 코드 - 동명이인 구분 핵심) | `120200123456` |
| `country` | 국적 | `대한민국` |
| `address` | 주소 | `서울특별시 강남구...` |

---

### 3.6 `inventorInfoArray` > `inventorInfo` (발명자 배열)

| XML 태그명 | 설명 |
| :--- | :--- |
| `name` | 발명자 성명 (국문) |
| `engName` | 발명자 성명 (영문) |
| `code` | 특허고객번호 |
| `country` | 국적 |
| `address` | 주소 |

---

### 3.7 `legalStatusInfoArray` > `legalStatusInfo` (법적상태/심사 이력 배열)

특허의 출원부터 심사청구, 의견제출통지(OA), 보정서 제출, 등록결정/거절결정까지의 모든 행정 이력이 시간순으로 들어있습니다. **PASO Docs의 OA 분석에 매우 중요한 데이터**입니다.

| XML 태그명 | 설명 | 예시 |
| :--- | :--- | :--- |
| `commonCodeName` | 서류/처분 명칭 | `의견제출통지서`, `보정서`, `등록결정서` |
| `documentEngName` | 영문 서류명 | `Notification of Reason for Refusal` |
| `documentNumber` | 서류 접수/발송 번호 | `9-5-2025-0123456-78` |
| `receiptDate` | 접수/발송 일자 (`YYYYMMDD`) | `20250610` |

---

### 3.8 `priorArtDocumentsInfoArray` > `priorArtDocumentsInfo` (선행기술 인용문헌 배열)

심사관이 심사 과정에서 인용한 선행특허 문헌 리스트입니다. **PASO Lens의 인용 네트워크 시각화(Citation Graph)에 직접 활용**됩니다.

| XML 태그명 | 설명 | 예시 |
| :--- | :--- | :--- |
| `documentsNumber` | 인용된 선행문헌 번호 (공개/등록번호 등) | `KR1020200012345A` |
| `examinerQuotationFlag` | 심사관 인용 여부 플래그 | `Y` |
